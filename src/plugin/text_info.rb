#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TextInfoPlugin -- oddb.org -- 22.05.2013 -- yasaka@ywesee.com
# ODDB::TextInfoPlugin -- oddb.org -- 30.01.2012 -- mhatakeyama@ywesee.com 
# ODDB::TextInfoPlugin -- oddb.org -- 17.05.2010 -- hwyss@ywesee.com 

require 'date'
require 'drb'
require 'mechanize'
require 'fileutils'
require 'config'
require 'thread'
require 'zip/zip'
require 'nokogiri'
require 'plugin/plugin'
require 'model/fachinfo'
require 'model/patinfo'
require 'view/rss/fachinfo'
require 'util/logfile'

module ODDB
  class TextInfoPlugin < Plugin
    attr_reader :updated_fis, :updated_pis
    CharsNotAllowedInBasename = /[^A-z0-9,\s\-]/
    def initialize app, opts={}
      super(app)
      @options = opts
      @parser = DRb::DRbObject.new nil, FIPARSE_URI
      @dirs = {
        :fachinfo => File.join(ODDB.config.data_dir, 'html', 'fachinfo'),
        :patinfo  => File.join(ODDB.config.data_dir, 'html', 'patinfo'),
      }
      @updated_fis = 0
      @updated_pis = 0
      @ignored_pseudos = 0
      @session_failures = 0
      @up_to_date_fis = 0
      @up_to_date_pis = 0
      @iksless = Hash.new{|h,k| h[k] = [] }
      @unknown_iksnrs = {}
      @failures = []
      @download_errors = []
      @companies = []
      @nonconforming_content = []
      @wrong_meta_tags = []
      @news_log = File.join ODDB.config.log_dir, 'textinfos.txt'
      @title  = ''       # target fi/pi name
      @format = :swissmedicinfo
      @target = :both
      @search_term = []
      # FI/PI names
      @updated  = []
      @skipped  = []
      @invalid  = []
      @notfound = []
    end
    def save_info type, name, lang, page, flags={}
      dir = File.join @dirs[type], lang.to_s
      FileUtils.mkdir_p dir
      name_base = name.gsub(/[\/\s\+:]/, '_')
      tmp = File.join dir, name_base + '.tmp.html'
      page.save tmp
      path = File.join dir, name_base + '.html'
      if File.exist?(path) && FileUtils.compare_file(tmp, path)
        flags.store lang, :up_to_date
      end
      FileUtils.mv tmp, path
=begin # skip all images
      # save images
      resource_dir = File.join ODDB::IMAGE_DIR, type.to_s, lang.to_s
      FileUtils.mkdir_p resource_dir
      # http://xxx.xxx.xx/data[/pictures]/xxx
      # http:/[/pictures].documed.ch/xxx
      page.images_with(:src => %r!/pictures!).each do |image|
        filename = File.basename(image.src.gsub(/\?px=[0-9]*$/, '')).strip
        img_file = File.join dir, name_base + '_files', filename
        # Host is required in Request Header
        image.fetch([], nil, {'Host' => URI.parse(image.src).host}).
          save(img_file)
        FileUtils.cp img_file, File.join(resource_dir, filename)
      end
=end
      path
    end
    def parse_fachinfo(path, styles=nil)
      @parser.parse_fachinfo_html(path, @format, @title, styles)
    end
    def parse_patinfo(path, styles=nil)
      @parser.parse_patinfo_html(path, @format, @title, styles)
    end
    def postprocess
      update_rss_feeds('fachinfo.rss', @app.sorted_fachinfos, View::Rss::Fachinfo)
    end
    def replace(new_ti, container, type) # description
      old_ti = container.send(type)
      if old_ti
        # support update with only a de/fr description
        %w[de fr].each do |lang|
          if old_ti.descriptions and desc = new_ti.descriptions[lang]
            old_ti.descriptions[lang] = desc
            old_ti.descriptions.odba_isolated_store
          end
        end
        @app.update(old_ti.pointer, {:descriptions => old_ti.descriptions})
      else
        @app.update(container.pointer, {type => new_ti.pointer})
      end
    end
    def store_fachinfo reg, languages
      @updated_fis += 1
      existing = reg.fachinfo
      ptr = Persistence::Pointer.new(:fachinfo).creator
      if existing
        ptr = existing.pointer
      end
      @app.update ptr, languages
    end
    def store_orphaned iksnr, info, point=:orphaned_fachinfo
      if info
        pointer = Persistence::Pointer.new point
        store = {
          :key       => iksnr,
          :languages => info,
        }
        @app.update pointer.creator, store
      end
    end
    def store_patinfo reg, languages
      @updated_pis +=1
      existing = reg.sequences.collect{ |seqnr, seq| seq.patinfo }.compact.first
      ptr = Persistence::Pointer.new(:patinfo).creator
      puts "store_patinfo existing #{existing} -> ptr #{ptr == nil} languages #{languages.keys} reg.iksnr #{reg.iksnr}"
      if existing
        ptr = existing.pointer
      end
      @app.update ptr, languages
    end
    def update_fachinfo name, iksnrs_from_xml, fis, fi_flags
      begin
        puts "update_fachinfo #{name} iksnr #{iksnrs_from_xml}"
        if iksnrs_from_xml.empty?
          @iksless[:fi].push name
        end
        ## Now that we have identified the pertinent iksnrs_from_xml, we can remove
        #  up-to-date fachinfos from the queue.
        if fi_flags[:de] && fi_flags[:fr] && !@options[:reparse]
          fis.clear
          @up_to_date_fis += 1
        end
        fachinfo = nil
        # assign infos.
        iksnrs_from_xml.each do |iksnr|
          if reg = @app.registration(iksnr)
            ## identification of Pseudo-Fachinfos happens at download-time.
            #  but because we still want to extract the iksnrs, we just mark them
            #  and defer inaction until here:
            unless fi_flags[:pseudo] || fis.empty?
              puts "update_fachinfo #{name} iksnr #{iksnr} store_fachinfo #{fi_flags}"
              fachinfo ||= store_fachinfo(reg, fis)
              replace fachinfo, reg, :fachinfo
            end
          else
            puts "update_fachinfo #{name} iksnr #{iksnr} store_orphaned"
            store_orphaned iksnr, fis, :orphaned_fachinfo
            @unknown_iksnrs.store iksnr, name
          end
        end
      rescue RuntimeError => err
        @failures.push err.message
        []
      end
    end

    def delete_patinfo iksnr, language
      puts "delete_patinfo iksnr #{iksnr} #{language}"
      return unless iksnr
      if reg = @app.registration(iksnr)          
          reg.each_sequence{
            |seq| 
                puts "delete_patinfo_pointer #{iksnr} #{seq.patinfo.pointer}"
                next unless seq.patinfo and seq.patinfo.pointer;
                @app.delete(seq.patinfo.pointer)
                @app.update(seq.pointer, :patinfo => nil)
                seq.odba_isolated_store
          }
      else
        puts "delete_patinfo nothing to do for #{iksnr} ??"
      end
    end
    
    # pis is a hash of language => html
    def update_patinfo name, iksnrs_from_xml, pis, pi_flags
      begin
        puts "update_patinfo #{name} iksnrs_from_xml #{iksnrs_from_xml} empty #{pis.empty?}"
        patinfo = nil
        iksnrs_from_xml.each do |iksnr|
          reg = @app.registration(iksnr)
          if reg
            unless pis.empty?
              puts "update_patinfo.pointer1 #{iksnr} #{patinfo and patinfo.pointer ? patinfo.pointer : 'nil'}"
              patinfo ||= store_patinfo(reg, pis)
              puts "update_patinfo.pointer2 #{iksnr} #{patinfo and patinfo.pointer ? patinfo.pointer : 'nil'}"
              reg.each_sequence do |seq|
                # cut connection to pdf patinfo
                puts "update_patinfo #{name} iksnr #{iksnr} update"
                if !seq.pdf_patinfo.nil? and !seq.pdf_patinfo.empty?
                  seq.pdf_patinfo = ''
                  @app.update(seq.pointer, {:pdf_patinfo => ''}, :text_info)
                  seq.odba_isolated_store
                end
                replace patinfo, seq, :patinfo
              end
            end
          else
            puts "update_patinfo #{name} iksnr #{iksnr} store_orphaned"
            store_orphaned iksnr, pis, :orphaned_patinfo
            @unknown_iksnrs.store iksnr, name
          end
        end
      rescue RuntimeError => err
        @failures.push err.message
        puts "update_patinfo RuntimeError #{err.message}"
        []
      end
    end
    
    def update_product name, fi_paths, pi_paths, fi_flags={}, pi_flags={}
      puts "update_product #{name} #{fi_paths}  #{pi_paths} #{fi_flags} #{pi_flags}"
      # parse pi and fi
      fis = {}
      fi_paths.each do |lang, path|
        fis.store lang, parse_fachinfo(path)
      end
      unless fis.empty?
        update_fachinfo name, fis, fi_flags
      end
      pis = {}
      ## there's no need to parse up-to-date patinfos
      #  if both of them are up-to-date
      if pi_flags[:de] && pi_flags[:fr] && !@options[:reparse]
        pi_paths.clear
        @up_to_date_pis += 1
      end
      pi_paths.each do |lang, path|
        pis.store lang, parse_patinfo(path)
      end
      unless pis.empty?
        update_patinfo name, pis, pi_flags
      end
    end
    def report
      if defined?(@inconsistencies)
        if @inconsistencies.size == 0
          return "Your database seems to be okay. No @inconsistencies found. #{@inconsistencies.inspect}"
        else
          return "Problems in your database?\n\n"+
                 "Check for inconsistencies in swissmedicinfo FI and PI found #{@inconsistencies.size} problems.\n\n#{@inconsistencies.inspect}\n\n"+
                 "You might fix the problems running an import of the following iksnrs #{@iksnrs_to_import.join(' ')}"
        end
      end
      unknown_size = @unknown_iksnrs.size
      @wrong_meta_tags ||= []
      @nonconforming_content ||= []
      @nonconforming_content = @nonconforming_content.uniq.sort
      unknown = @unknown_iksnrs.collect { |iksnr, name|
        "#{name} (#{iksnr})"
      }.join("\n")
      case @target
      when :both
        [
          "Searched for #{@search_term.join(', ')}",
          "Stored #{@updated_fis} Fachinfos",
          "Ignored #{@ignored_pseudos} Pseudo-Fachinfos",
          "Ignored #{@up_to_date_fis} up-to-date Fachinfo-Texts",
          "Stored #{@updated_pis} Patinfos",
          "Ignored #{@up_to_date_pis} up-to-date Patinfo-Texts", nil,
          "Checked #{@companies.size} companies",
          @companies.join("\n"), nil,
          "Unknown Iks-Numbers: #{unknown_size}",
          unknown, nil,
          "Fachinfos without iksnrs: #{@iksless[:fi].size}",
          @iksless[:fi].join("\n"), nil,
          #"Patinfos without iksnrs: #{@iksless[:pi].size}",
          #@iksless[:pi].join("\n"), nil,
          "Session failures: #{@session_failures}", nil,
          "Download errors: #{@download_errors.size}",
          @download_errors.join("\n"), nil,
          "Parse Errors: #{@failures.size}",
          @failures.join("\n"),
          # names
          @updated.join("\n"),
          @skipped.join("\n"),
          @invalid.join("\n"),
          @notfound.join("\n"),nil,
          "#{@nonconforming_content.size} non conforming contents: ",  @nonconforming_content.join("\n"),
          "#{@wrong_meta_tags.size} wrong metatags: ",                 @wrong_meta_tags.join("\n"),          
        ].join("\n")
      when :fi
        [
          "Searched for #{@search_term.join(', ')}",
          "Stored #{@updated_fis} Fachinfos",
          "Ignored #{@ignored_pseudos} Pseudo-Fachinfos",
          "Ignored #{@up_to_date_fis} up-to-date Fachinfo-Texts", nil,
          "Checked #{@companies.size} companies",
          @companies.join("\n"), nil,
          "Unknown Iks-Numbers: #{unknown_size}",
          unknown, nil,
          "Fachinfos without iksnrs: #{@iksless[:fi].size}",
          @iksless[:fi].join("\n"), nil,
          "Session failures: #{@session_failures}", nil,
          "Download errors: #{@download_errors.size}",
          @download_errors.join("\n"), nil,
          "Parse Errors: #{@failures.size}",
          # names
          @failures.join("\n"),
          @updated.join("\n"),
          @skipped.join("\n"),
          @invalid.join("\n"),
          @notfound.join("\n"),nil,
          "#{@nonconforming_content.size} non conforming contents: ",  @nonconforming_content.join("\n"),
          "#{@wrong_meta_tags.size} wrong metatags: ",                 @wrong_meta_tags.join("\n"),          
        ].join("\n")
      when :pi
        [
          "Searched for #{@search_term.join(', ')}",
          "Stored #{@updated_pis} Patinfos",
          "Ignored #{@up_to_date_pis} up-to-date Patinfo-Texts", nil,
          "Checked #{@companies.size} companies",
          @companies.join("\n"), nil,
          "Unknown Iks-Numbers: #{unknown_size}",
          unknown, nil,
          #"Patinfo without iksnrs: #{@iksless[:pi].size}",
          #@iksless[:pi].join("\n"), nil,
          "Session failures: #{@session_failures}", nil,
          "Download errors: #{@download_errors.size}",
          @download_errors.join("\n"), nil,
          "Parse Errors: #{@failures.size}",
          @failures.join("\n"),
          # names
          @updated.join("\n"),
          @skipped.join("\n"),
          @invalid.join("\n"),
          @notfound.join("\n"),nil,
          "#{@nonconforming_content.size} non conforming contents: ",  @nonconforming_content.join("\n"),
          "#{@wrong_meta_tags.size} wrong metatags: ",                 @wrong_meta_tags.join("\n"),          
        ].join("\n")
      end
    end
    def setup_default_agent
      unless @agent
        @agent = Mechanize.new
        @agent.user_agent = 'Mozilla/5.0 (X11; Linux x86_64; rv:16.0) Gecko/20100101 Firefox/16.0'
        @agent.redirect_ok         = true
        @agent.redirection_limit   = 5
        @agent.follow_meta_refresh = true
        @agent.ignore_bad_chunking = true
      end
      @agent
    end

##
# == interface 1 (classic) compendium
# == interface 1 (classic)
#
# TODO
#  * remove old methods
#
# NOTE
#  * import_name terms, agent=init_agent
#  * import_fulltext terms, agent=init_agent
#  * import_company, names, agent=nil, target=:both
#  * import_news agent=init_agent
    def init_agent
      setup_default_agent
      @agent.user_agent = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_4_11; de-de) AppleWebKit/525.18 (KHTML, like Gecko) Version/3.1.2 Safari/525.22"
      @agent
    end
    def init_searchform agent
      url = ODDB.config.text_info_searchform \
        or raise 'please configure ODDB.config.text_info_searchform to proceed'
      page = agent.get(url)
      form, = page.form_with :name => 'frmNutzungsbedingungen'
      if form
        if btn = form.button_with(:name => 'btnAkzeptieren')
          page = agent.submit form, btn
        end
      end
      page
    end
    def search type, term, agent
      page = init_searchform agent
      form = page.form_with :name => 'frmSearchForm'
      unless type == 'rbPraeparat' ## default value, clicking leads to an error
        form.radiobutton_with(:value => type).click
      end
      form['txtSearch'] = term
      agent.submit form
    end
    def detect_session_failure page
      !page.form_with(:name => 'frmSearchForm').nil?
    end
    def download_info type, name, agent, form, eventtarget
      paths = {}
      flags = {}
      de, fr = nil
      de = submit_event agent, form, eventtarget
      if detect_session_failure(de)
        @session_failures += 1
        form = rebuild_resultlist agent
        de = submit_event agent, form, eventtarget
      end
      if match = /(Pseudo-Fach|Produkt)information/i.match(de.body)
        @ignored_pseudos += 1
        flags.store :pseudo, true
      end
      paths.store :de, save_info(type, name, :de, de, flags)
      fr = agent.get de.uri.to_s.gsub('lang=de', 'lang=fr')
      if detect_session_failure(fr)
        @session_failures += 1
        form = rebuild_resultlist agent
        de = submit_event agent, form, eventtarget
        fr = agent.get de.uri.to_s.gsub('lang=de', 'lang=fr')
      end
      paths.store :fr, save_info(type, name, :fr, fr, flags)
      [paths, flags]
    rescue Mechanize::ResponseCodeError
      @download_errors.push name
      [paths, flags]
    end
    def import_product name, agent, form, fi_target, pi_target
      fi_paths = {}
      fi_flags = {}
      pi_paths = {}
      pi_flags = {}
      if fi_target
        fi_paths, fi_flags = download_info :fachinfo, name, agent, form, fi_target
      end
      if pi_target
        pi_paths, pi_flags = download_info :patinfo, name, agent, form, pi_target
      end
      update_product name, fi_paths, pi_paths || {}, fi_flags, pi_flags || {}
    end
    def import_products page, agent, target=:both
      @target = target
      form = page.form_with :name => /frmResult(Produkte|hForm)/
      case target
      when :both
        fi_sources = identify_eventtargets page, /dtgFachinfo/
        pi_sources = identify_eventtargets page, /dtgPatienteninfo/
        fi_sources.sort.each do |name, eventtarget|
          import_product name, agent, form, eventtarget, pi_sources[name]
        end
      when :pi
        pi_sources = identify_eventtargets page, /dtgPatienteninfo/
        pi_sources.sort.each do |name, eventtarget|
          import_product name, agent, form, nil, eventtarget
        end
      end
    end
    def rebuild_resultlist agent
      method, term = @current_search
      page = self.send method, term, agent
      form = page.form_with :name => 'frmResulthForm'
      if @current_eventtarget
        products = submit_event agent, form, @current_eventtarget
        form = products.form_with :name => 'frmResultProdukte'
      end
      form
    end
    def eventtarget string
      if match = /doPostBack\('([^']+)'.*\)/.match(string.to_s)
        match[1]
      end
    end
    
    def TextInfoPlugin::get_iksnrs_from_string(string)
      iksnrs = []
      src = string.gsub(/[^0-9,\s]/, "")
      if(matches = src.strip.scan(/\d{5}|\d{2}\s*\d{3}|\d\s*{5}/))
        # support some wrong in numbers [000nnn] (too many 0)
        if (matches.length == 2 && matches.first =~ /^0{3}\d{2}$/) and
            (matches.first.length == 5 && matches.last.length == 1 )
          matches = [matches.first[1..-1] + matches.last]
        end
        _iksnr = ''
        matches.map do |iksnr|
          # support [nnnnn] and [n,n,n,n,n]
          _iksnr << iksnr.gsub(/[^0-9]/, '')
          if _iksnr.length == 5
            iksnrs << _iksnr
            _iksnr = ''
          end
        end
      end
      iksnrs.uniq!
      iksnrs
    rescue => e
      puts "get_iksnrs_from_string: string #{string} rescued from #{e}"
      []
    end
    
    def detect_format(html)
      return :swissmedicinfo if html.index('section1') or html.index('Section7000')
      html.match(/MonTitle/i) ? :compendium : :swissmedicinfo
    end    
    def extract_iksnrs languages
      iksnrs = []
      languages.each_value do |doc|
        return TextInfoPlugin::get_iksnrs_from_string(doc.iksnrs.to_s)
      end
    end
    
    def identify_eventtargets page, ptrn
      eventtargets = {}
      page.links_with(:href => ptrn).each do |link|
        eventtargets.store link.text, eventtarget(link.href)
      end
      eventtargets
    end
    def search_company name, agent
      search 'rbFirma', name, agent
    end
    def search_fulltext term, agent
      search 'rbFulltext', term, agent
    end
    def search_product name, agent
      search 'rbPraeparat', name, agent
    end
    def submit_event agent, form, eventtarget, *args
      max_retries = ODDB.config.text_info_max_retry
      form['__EVENTTARGET'] = eventtarget
      agent.submit form, *args
    rescue Mechanize::ResponseCodeError => err
      retries ||= max_retries
      if retries > 0
        retries -= 1
        sleep max_retries - retries
        retry
      else
        raise
      end
    end
    def log_news lines
      FileUtils.mkdir_p(File.dirname(@news_log))
      File.open(@news_log, 'w') do |fh|
        fh.print lines.join("\n")
      end
    end
    def true_news news, old_news
      news - old_news
    end
    def old_textinfo_news
      begin
        File.readlines(@news_log).collect do |line|
          line.strip
        end
      rescue Errno::ENOENT
        []
      end
    end
    def textinfo_news agent=init_agent
      url = ODDB.config.text_info_newssource \
        or raise 'please configure ODDB.config.text_info_newssource to proceed'
      names = {
        :fi => [],
        :pi => [],
      }
      page = agent.get url
      list = page.search('.//rss/channel/item')
      unless list.empty?
        list.each do |node|
          type = nil
          node.children.each do |element|
            if element.text? and element.text =~ /MonType=(fi|pi)$/
              type = $1.downcase.to_sym
              break
            end
          end
          if type
            names[type] << node.at('title').content
          end
        end
      end
      names
    end
    def import_companies page, agent, target=:both
      @target = target
      form = page.form_with :name => 'frmResulthForm'
      page.links_with(:href => /Linkbutton1/).each do |link|
        if et = eventtarget(link.href)
          @companies.push link.text
          @current_eventtarget = et
          products = submit_event agent, form, et
          import_products products, agent, target
        end
      end
    end
    def import_company names, agent=nil, target=:both
      @target = target
      agent = init_agent if agent.nil?
      @search_term += names.to_a
      names.to_a.each do |name|
        @current_search = [:search_company, name]
        # search for company
        page = search_company name, agent
        # import each company from the result
        import_companies page, agent, target
      end
    end
    def import_fulltext terms, agent=init_agent
      @search_term += terms.to_a
      terms.to_a.each do |term|
        @current_search = [:search_fulltext, term]
        page = search_fulltext term, agent
        import_products page, agent
      end
    end
    def import_name terms, agent=init_agent
      @search_term += terms.to_a
      terms.to_a.each do |term|
        @current_search = [:search_product, term]
        page = search_product term, agent
        import_products page, agent
      end
    end
    def import_news agent=init_agent
      updated = []
      old_news = old_textinfo_news
      news = textinfo_news(agent)
      news.keys.each do |type|
        if update_name_list = true_news(news[type], old_news)
          import_name(update_name_list, agent)
          log_news(news[type])
          type == :fi ? postprocess : nil
          updated.concat update_name_list
        end
      end
      return !updated.empty?
    end

# == interface 2 (new) (was for documed)

# == interface 3 (swissmedicinfo)
#
# TODO
#  * refactor (this is temporary solution, to refactor if swissmedicinfo improves FI/PI format)
#
    def swissmedicinfo_index(state)
      index = {}
      %w[DE FR].each do |lang|
        url  = "http://www.swissmedicinfo.ch/?Lang=#{lang}"
        home = @agent.get(url)
        # behave as javascript click
        form = home.form_with(:id => 'ctl01')
        form['__EVENTTARGET']   = "ctl00$HeaderContent$ucSpecialSearch1$LB#{state}Auth"
        form['__EVENTARGUMENT'] = ''
        res = form.submit
        names = {}
        {# typ => [name, date]
          'FI' => [1, 3],
          'PI' => [0, 2],
        }.each_pair do |typ, i|
          _names = []
          res.search("//table[@id='MainContent_ucSearchResult1_ucResultGrid#{typ}_GVMonographies']/tr").each do |tr|
            tds = tr.search('td')
            unless tds.empty?
              _names << [tds[i.first].text, tds[i.last].text]
            end
          end
          names[typ.downcase.intern] =
            _names.sort_by do |name, date|
              Date.strptime(date, "%d.%m.%Y")
            end.reverse!
        end
        index[lang.downcase.intern] = names
      end
      index
    end
    ##
    # = import_product2
    #
    # ::Return
    #   * index = {
    #       :new    => {
    #         :de => {:fi => [['FI-NAME', 'DATE']], :pi => [['PI-NAME', 'DATE']]},
    #         :fr => {:fi => [], :pi => []},
    #       },
    #       :change => {
    #         :de => {:fi => [], :pi => []},
    #         :fr => {:fi => [], :pi => []},
    #       }
    #     }
    def textinfo_swissmedicinfo_index
      setup_default_agent
      url = 'http://www.swissmedicinfo.ch/'
      # accept form
      accept = @agent.get(url)
      form   = accept.form_with(:id => 'ctl01')
      button = form.button_with(:name => 'ctl00$MainContent$btnOK')
      form.submit(button) # discard
      index = {}
      %w[New Change].each do |state|
        index[state.downcase.intern] = swissmedicinfo_index(state)
      end
      index      
    end
    
    def TextInfoPlugin.match_iksnr
      /Zulassungsnummer[^\d]*([\d’ ]+).*(Wo|Packungen)/m
    end
    
    def TextInfoPlugin.find_iksnr_in_string(string, iksnr)
      nr  = ''
      string.each_char{ 
        |char|
          nr << char if char >= '0' and char <= '9'
          nr.eql?(iksnr) ? break : nr  = '' if char.eql?(' ') or char.eql?(',')
      }
      nr
    end
        
    def textinfo_swissmedicinfo_company_index(company, target)
      swissmedicinfo_xml
      ids = []
      @doc.xpath(".//medicalInformation[regex(., '#{company}')]", Class.new {
        def regex node_set, regex
          node_set.find_all { |node| node.at('authHolder').text =~ /#{regex}/i }
        end
      }.new).each{ |x| 
                    ids += TextInfoPlugin::get_iksnrs_from_string(x.at('authNrs').text)
                   }
      puts "textinfo_swissmedicinfo_company_index #{company} #{target.inspect} fachinfo #{ids.sort.uniq.join(',')}. Used #{@options[:xml_file]}"
      ids.sort.uniq
    end

    def download_swissmedicinfo_xml
      setup_default_agent
      url  = "http://download.swissmedicinfo.ch/Accept.aspx?ReturnUrl=%2f"
      dir  = File.join(ODDB.config.data_dir, 'xml')
      FileUtils.mkdir_p dir
      name = 'swissmedicinfo'
      zip = File.join(dir, "#{name}.zip")
      response = nil
      if home = @agent.get(url)
        form = home.form_with(:id => 'Form1')
        bttn = form.button_with(:name => 'ctl00$MainContent$btnOK')
        if page = form.submit(bttn)
          form = page.form_with(:id => 'Form1')
          bttn = form.button_with(:name => 'ctl00$MainContent$BtnYes')
          response = form.submit(bttn)
        end
      end
      if response
        tmp = File.join(dir, name + '.tmp.zip')
        response.save_as(tmp)
        FileUtils.mv(tmp, zip)
        xml = ''
        Zip::ZipFile.foreach(zip) do |entry|
          if entry.name =~ /^AipsDownload_/iu
            entry.get_input_stream { |io| xml = io.read }
          end
        end
        file = File.join(dir, 'AipsDownload_latest.xml')
        File.open(file, 'w') { |fh| fh.puts(xml) }
      end
    end
    def extract_matched_content(name, type, lang)
      content = nil, styles = nil, title = nil, iksnrs = nil
      return content unless @doc and name
      nameForRegexp = name.gsub('"','.')
      path  = "//medicalInformation[@type='#{type[0].downcase + 'i'}' and @lang='#{lang.to_s}']/title[match(., \"#{nameForRegexp}\")]"
      match = @doc.xpath(path, Class.new do
        def match(node_set, name)
          found_node = catch(:found) do
            node_set.find_all do |node|
              title = node.text.gsub(CharsNotAllowedInBasename, '')
              name  = name.gsub(CharsNotAllowedInBasename, '')
              throw :found, node if title == name
              false
            end
            nil
          end
          found_node ? [found_node] : []
        end
      end.new).first
      if match
        content = match.parent.at('./content')
        styles  = match.parent.at('./style').text
        title   = match.parent.at('./title').text
        iksnrs  = TextInfoPlugin::get_iksnrs_from_string(match.parent.at('./authNrs').text)
        unless iksnrs.size > 0
          @wrong_meta_tags << "#{match.parent.at('./authNrs')} authNrs-text: #{match.parent.at('./authNrs').text}"
        end
      end
      return content, styles, title, iksnrs
    end
    def extract_matched_name(iksnr, type, lang)
      name = nil
      return name unless @doc
      path  = "//medicalInformation[@type='#{type[0].downcase + 'i'}' and @lang='#{lang.to_s}']/authNrs"
      @doc.xpath(path, Class.new do
        def match(node_set, iksnr)
          node_set.find_all do |node|
            iksnr.eql?(TextInfoPlugin.find_iksnr_in_string(node.text, iksnr))
          end
        end
      end.new).each{ 
        |x| 
            if iksnr.eql?(TextInfoPlugin.find_iksnr_in_string(x.text, iksnr))
              name = x.parent.at('./title').text 
              puts "extract_matched_name #{iksnr} #{type} as '#{type[0].downcase + 'i'}' lang '#{lang.to_s}' path is #{path} returns #{name}"
              return name
            end
      }
      @notfound << "  IKSNR-not found #{iksnr.inspect} : #{type} - #{lang.to_s.upcase}"
      return name
    end
    def extract_image(name, type, lang, dist, iksnrs)
      if File.exists?(dist)
        resource_dir = (File.join(ODDB::IMAGE_DIR, type.to_s, lang.to_s))
        FileUtils.mkdir_p(resource_dir)
        html = File.open(dist, 'r:utf-8').read
        if html =~ /<img\s/
          images = Nokogiri::HTML(html).search('//img')
          html = nil
          name_base = File.basename(name.gsub(/®/, '').gsub(/[^A-z0-9]/, '_')).strip
          dir = File.join(resource_dir, name_base + '_files')
          FileUtils.mkdir_p(dir)
          images.each_with_index do |img, i|
            type,src = img.attributes['src'].to_s.split(',')
            if type =~ /^data:image\/(jp[e]?g|gif|png|x-wmf);base64$/
              file = File.join(dir, "#{i + 1}.#{$1}")
              File.open(file, 'wb'){ |f| f.write(Base64.decode64(src)) }
              if /x-wmf/.match(type)
                @nonconforming_content << "#{iksnrs}: '#{@title}' with non conforming #{type} element"
              end
            end
          end
        end
      end
    end
    def strange?(info)
      if info.nil? or !info.respond_to?(:name)
        :nil
      elsif info.name.to_s.length > 2700 # Maybe all chapters are in title ;(
        :invalid
      else
        false # expected
      end
    end
    def parse_and_update(names, type)
      puts "parse_and_update #{names} #{type}"
      # names eg. { :de => 'Alacyl'}
      iksnrs = []
      infos  = {}
      return [iksnrs,infos] unless @doc
      iksnrs_from_xml = nil
      name  = ''
      [:de, :fr].each do |lang|
        next unless names[lang]
        name = names[lang]
        saved = iksnrs_from_xml
        content, styles, title, iksnrs_from_xml = extract_matched_content(name, type, lang)
        unless saved == nil or saved != iksnrs_from_xml
          puts "parse_and_update mismatch in #{iksnr} #{lang} saved #{saved} new #{iksnrs_from_xml}"
        end
        if content
          html = Nokogiri::HTML(content.to_s).to_s
          @title  = name
          @format = detect_format(html)
          # save as tmp
          path = File.join(ODDB.config.data_dir, 'html', type, lang.to_s)
          dist = File.join(path, name.gsub(CharsNotAllowedInBasename, '_') + '_swissmedicinfo.html')
          temp = dist + '.tmp'
          FileUtils.makedirs(File.dirname(dist))
          File.open(temp, 'w') { |fh| fh.puts(html) }
          File.open(dist.sub('.html', '.styles'), 'w+') { |fh| fh.puts(styles) }
          content,html = nil,nil
          update = false
          if !@options[:reparse] and File.exists?(dist)
            if File.size(dist) != File.size(temp)
              update = true
            else
              @up_to_date_fis += 1 if type == 'fachinfo'
              @up_to_date_pis += 1 if type == 'patinfo'
            end
          else
            update = true
          end
          if update
            FileUtils.mv(temp, dist)
            extract_image(name, type, lang, dist, iksnrs_from_xml)
            puts "parse_and_update: calls parse_#{type} dist #{dist} iksnrs_from_xml #{iksnrs_from_xml.inspect} #{File.basename(dist)}, name #{name} #{lang} title #{title}"
            puts "      Mismatch between title #{title} and name #{name}" unless name.eql?(title)
            infos[lang] = self.send("parse_#{type}", dist, styles)
            File.open(dist.sub('.html', '.yaml'), 'w+') { |fh| fh.puts(infos[lang].to_yaml) }
          else
            File.unlink(temp)
          end
        end
      end
      unless infos.empty?
        _infos = {}
        [:de, :fr].map do |lang|
          unless strange?(infos[lang])
            _infos[lang] = infos[lang]
          end
        end
        self.send("update_#{type}", name, iksnrs_from_xml, _infos, {})
      end
      [iksnrs, infos]
    end
    def import_info(keys, names, state)
      puts "import_info: #{keys} names #{names}"
      keys.each_pair do |typ, type|
        next if names[:de].nil? or names[:de][typ].nil?
        # This importer expects same order of names in DE and FR, come from swissmedicinfo.
        names.each_pair do |lang, infos|
          infos[typ].each do |name, date|
            iksnrs,infos = parse_and_update({lang => name}, type)
            puts "import_info: #{keys} names #{names} iksnrs #{iksnrs}"
            delete_patinfo iksnrs, lang if infos.empty? and type.eql?('patinfo')

            # report
            unless infos.empty?
              info = strange?(infos[lang])
              if info == :nil
                @notfound <<
                  "  NOTFOUND : #{type.capitalize} - #{lang.to_s.upcase} - #{name}"
              elsif info == :invalid
                @invalid <<
                  "  INVALID : #{type.capitalize} - #{lang.to_s.upcase} - #{name}"
              end
            end
            date = (date ? " - #{date}" : '')
            nrs  = (!iksnrs.empty? ? " - #{iksnrs.inspect}" : '')
            unless iksnrs.empty?
              next if name.nil? or name.empty?
              next if !infos.empty? and strange?(infos[lang])
              @updated <<
                "  #{state.to_s.upcase} : #{type.capitalize} - #{lang.to_s.upcase} - #{name}#{date}#{nrs}"
            else
              next if name.nil? or name.empty?
              @skipped <<
                "  #{state.to_s.upcase} : #{type.capitalize} - #{lang.to_s.upcase} - #{name}#{date}"
            end
          end
        end
      end
    end
    def title_and_keys_by(target)
      if target == :fi
        [target.to_s.upcase, {:fi => 'fachinfo'}]
      elsif target == :pi
        [target.to_s.upcase, {:pi => 'patinfo'}]
      else #both
        ['FI/PI', {:fi => 'fachinfo', :pi => 'patinfo'}]
      end
    end
    def report_sections_by(title)
      [
        ["New/Updates #{title} from swissmedicinfo.ch"], # updated
        ["Skipped #{title} form swissmedicinfo.ch"],     # skipped
        ["Invalid #{title} from swissmedicXML"],         # invalid
        ["Not found #{title} in swissmedicXML"],         # notfound
      ]
    end
    def swissmedicinfo_xml(xml_file = File.join(ODDB.config.data_dir, 'xml', 'AipsDownload_latest.xml'))
      if @options[:xml_file]
        xml_file = @options[:xml_file]
      end
      @doc = Nokogiri::XML(File.open(xml_file,'r').read)
    end
    
    def logCheckActivity(msg)
      puts msg
      if not defined?(@checkLog) or not @checkLog
        name = LogFile.filename('check_swissmedicno_fi_pi', Time.now)
        puts "Opening #{name}"
        FileUtils.makedirs(File.dirname(name))
        @checkLog = File.open(name, 'w+') 
      end
      @checkLog.puts(msg)
    end
    
    def check_swissmedicno_fi_pi(options = {}, delete_patinfo = false)
      logCheckActivity "check_swissmedicno_fi_pi #{options} \n#{Time.now}"
      logCheckActivity "check_swissmedicno_fi_pi found  #{@app.registrations.size} registrations and #{@app.sequences.size} sequences"
      @inconsistencies = []
      @iksnrs_to_import = []
      nrDeletes = 0
      @app.registrations.each{
        |aReg| 
          reg= aReg[1]; 
          if  reg.fachinfo and not reg.fachinfo.iksnrs.index(reg.iksnr) 
            info = [aReg[1], reg.fachinfo.iksnr, reg.fachinfo.pointer]
            @inconsistencies << info
            @iksnrs_to_import << reg.fachinfo.iksnr
            logCheckActivity "check_swissmedicno_fi_pi inconsistency #{info}"
          end
          foundPatinfo = false
          reg.sequences.each {|aSeq|
                              seq = aSeq[1]
                              foundPatinfo = true if seq.patinfo and seq.patinfo.pointer
                              next if (seq.patinfo == nil or  seq.patinfo.name_base == nil); 
                              if not seq.patinfo.name_base.split()[0].eql?(reg.name_base.split()[0])
                                info =[ seq.patinfo.name_base, reg.iksnr, reg.name_base, seq.patinfo.pointer]
                                logCheckActivity "check_swissmedicno_fi_pi inconsistency #{info}"
                                @inconsistencies << info
                                @iksnrs_to_import << reg.iksnr
                                if delete_patinfo                            
                                  logCheckActivity "delete_patinfo_pointer #{nrDeletes}: #{reg.iksnr} #{reg.name_base} #{seq.seqnr} #{seq.patinfo.name_base} #{seq.patinfo.pointer}"
                                  @app.delete(seq.patinfo.pointer)
                                  @app.update(seq.pointer, :patinfo => nil)
                                  seq.odba_isolated_store
                                  nrDeletes += 1
                                end
                              end
                             } 
          unless foundPatinfo
            # seems to be a valid case, e.g. Alutard http://ch.oddb.org/de/gcc/search/zone/drugs/search_query/Alutard%20/search_type/st_sequence#best_result
            info =[ 'neither FI nor PI for', reg.iksnr, reg.name_base]
            logCheckActivity "check_swissmedicno_fi_pi  #{info}"
            @inconsistencies << info
            @iksnrs_to_import << reg.iksnr
          end if false
      }
      logCheckActivity "check_swissmedicno_fi_pi found  #{@inconsistencies.size} inconsistencies.\nDeleted #{nrDeletes} patinfos."
      logCheckActivity "check_swissmedicno_fi_pi found  #{@inconsistencies.uniq.inspect} \n#{Time.now}"
      logCheckActivity "check_swissmedicno_fi_pi #{@iksnrs_to_import.size} iksnrs_to_import  are  \n#{@iksnrs_to_import.sort.uniq.join(' ')}"
      @iksnrs_to_import = @iksnrs_to_import.sort.uniq
      true
    end
  
    def update_swissmedicno_fi_pi(options = {})
      logCheckActivity "update_swissmedicno_fi_pi #{options} \n#{Time.now}"
      threads = []
      @iksnrs_to_import =[]
      threads << Thread.new do
        check_swissmedicno_fi_pi(options, true)[0..10]
      end
      threads.map(&:join)
      logCheckActivity "update_swissmedicno_fi_pi reimport #{@iksnrs_to_import.sort.size} iksnrs_to_import \n#{@iksnrs_to_import.inspect}"
      @iksnrs_to_import = [ '-99999'] if @iksnrs_to_import.size == 0
      threads.map(&:join)
      threads << Thread.new do
        # set correct options to force a reparse (reimport)
        @options[:reparse] = true
        @options[:download] = false
        import_swissmedicinfo_by_iksnrs(@iksnrs_to_import, :both)
      end
      threads.map(&:join)
      logCheckActivity "update_swissmedicno_fi_pi finished"
      true
    end

    def import_swissmedicinfo_by_index(index, target)
      puts "import_swissmedicinfo_by_index #{index} #{target}"
      title,keys = title_and_keys_by(target)
      @updated,@skipped,@invalid,@notfound = report_sections_by(title)
      @doc = swissmedicinfo_xml
      index.each_pair do |state, names|
        import_info(keys, names, state)
      end
      @doc = nil
    end
    def import_swissmedicinfo_by_iksnrs(iksnrs, target)
      puts "import_swissmedicinfo_by_iksnrs #{iksnrs.inspect} target #{target}"
      title,keys = title_and_keys_by(target)
      @updated,@skipped,@invalid,@notfound = report_sections_by(title)
      @doc = swissmedicinfo_xml
      iksnrs.each do |iksnr|
        names = Hash.new{|h,k| h[k] = {} }
        puts "import_swissmedicinfo_by_iksnrs iksnr #{iksnr.inspect} #{names.inspect}"
        [:de, :fr].each do |lang|
          keys.each_pair do |typ, type|
            names[lang][typ] = [extract_matched_name(iksnr.strip, type, lang)]
          end
        end
        import_info(keys, names, :isknr)
      end
      @doc = nil
    end

    def import_swissmedicinfo_by_companies(companies, target)
      iksnrs = []
      companies.each do |company|
        @companies << company
        iksnrs += textinfo_swissmedicinfo_company_index(company, target)
      end
      import_swissmedicinfo_by_iksnrs(iksnrs, target)
    end

    def import_swissmedicinfo(target=:both)
      target = @options[:target] if @options[:target]
      threads = []
      if @options[:download] != false
        threads << Thread.new do
          download_swissmedicinfo_xml
        end
      end
      if @options[:companies] and @options[:companies].size > 0
        threads.map(&:join)
        import_swissmedicinfo_by_companies(@options[:companies], target)        
      elsif @options[:iksnrs].nil? or @options[:iksnrs].empty?
        index = {}
        threads << Thread.new do
          index = textinfo_swissmedicinfo_index
        end
        threads.map(&:join)
        import_swissmedicinfo_by_index(index, target)
        index = nil
      else
        threads.map(&:join)
        import_swissmedicinfo_by_iksnrs(@options[:iksnrs], target)
      end
      if @options[:download] != false
        puts "job is done. now postprocess works ..."
        postprocess
      end
      true # report
    end
  end
end
