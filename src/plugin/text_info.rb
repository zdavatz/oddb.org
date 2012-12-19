#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TextInfoPlugin -- oddb.org -- 19.12.2012 -- yasaka@ywesee.com
# ODDB::TextInfoPlugin -- oddb.org -- 30.01.2012 -- mhatakeyama@ywesee.com 
# ODDB::TextInfoPlugin -- oddb.org -- 17.05.2010 -- hwyss@ywesee.com 

require 'date'
require 'drb'
require 'mechanize'
require 'fileutils'
require 'config'
require 'plugin/plugin'
require 'model/fachinfo'
require 'model/patinfo'
require 'view/rss/fachinfo'

module ODDB
  class TextInfoPlugin < Plugin
    attr_reader :updated_fis, :updated_pis
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
      @news_log = File.join ODDB.config.log_dir, 'textinfos.txt'
      @new_format_flag = false
      @target = :both
      @search_term = []
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
      path
    end
    def parse_fachinfo path
      @parser.parse_fachinfo_html(path, @new_format_flag)
    end
    def parse_patinfo path
      @parser.parse_patinfo_html(path, @new_format_flag)
    end
    def postprocess
      update_rss_feeds('fachinfo.rss', @app.sorted_fachinfos, View::Rss::Fachinfo)
    end
    def replace text_info, container, type
      old_ti = container.send type
      @app.update container.pointer, type => text_info.pointer
      if old_ti && old_ti.empty?
        @app.delete old_ti.pointer
      end
    end
    def store_fachinfo languages
      @updated_fis += 1
      pointer = Persistence::Pointer.new(:fachinfo)
      @app.update(pointer.creator, languages)
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
      existing = reg.sequences.collect do |seqnr, seq|
        seq.patinfo end.compact.first
      ptr = Persistence::Pointer.new(:patinfo).creator
      if existing
        ptr = existing.pointer
      end
      @app.update ptr, languages
    end
    def update_fachinfo name, fis, fi_flags
      begin
        # identify registration
        iksnrs = extract_iksnrs fis
        if iksnrs.empty?
          @iksless[:fi].push name
        end
        ## Now that we have identified the pertinent iksnrs, we can remove
        #  up-to-date fachinfos from the queue.
        if fi_flags[:de] && fi_flags[:fr] && !@options[:reparse]
          fis.clear
          @up_to_date_fis += 1
        end
        fachinfo = nil
        # assign infos.
        iksnrs.each do |iksnr|
          if reg = @app.registration(iksnr)
            ## identification of Pseudo-Fachinfos happens at download-time.
            #  but because we still want to extract the iksnrs, we just mark them
            #  and defer inaction until here:
            unless fi_flags[:pseudo] || fis.empty?
              fachinfo ||= store_fachinfo(fis)
              replace fachinfo, reg, :fachinfo
            end
          else
            store_orphaned iksnr, fis, :orphaned_fachinfo
            @unknown_iksnrs.store iksnr, name
          end
        end
      rescue RuntimeError => err
        @failures.push err.message
      end
    end
    def update_patinfo name, pis, pi_flags
      begin
        iksnrs = extract_iksnrs pis
        if iksnrs.empty?
          @iksless[:pi].push name
        end
        patinfo = nil
        iksnrs.each do |iksnr|
          if reg = @app.registration(iksnr)
            unless pis.empty?
              patinfo ||= store_patinfo(reg, pis)
              reg.each_sequence do |seq|
                replace patinfo, seq, :patinfo
              end
            end
          else
            store_orphaned iksnr, pis, :orphaned_patinfo
            @unknown_iksnrs.store iksnr, name
          end
        end
      rescue RuntimeError => err
        @failures.push err.message
      end
    end
    def update_product name, fi_paths, pi_paths, fi_flags={}, pi_flags={}
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
      unknown_size = @unknown_iksnrs.size
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
          @failures.join("\n"),
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
        ].join("\n")
      end
    end

##
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
      agent = Mechanize.new
      agent.user_agent = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_4_11; de-de) AppleWebKit/525.18 (KHTML, like Gecko) Version/3.1.2 Safari/525.22"
      agent
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
    def extract_iksnrs languages
      iksnrs = []
      languages.each_value do |doc|
        src = doc.iksnrs.to_s.gsub("'", "")
        if(match = src.match(/[0-9]{3,5}(?:\s*,\s*[0-9]{3,5})*/u))
          iksnrs.concat match.to_s.split(/\s*,\s*/u)
        end
      end
      iksnrs.collect! do |iksnr| sprintf("%05i", iksnr.to_i) end
      iksnrs.uniq!
      iksnrs
    rescue
      []
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

##
# == interface 2 (new)
#
# TODO
#  * rename method xxx2 to xxx
#  * refactor search2
#
# NOTE
#  * import_company2(name)
#  * import_companies2(company_names, target=:both, agent=nil)
#  * import_news2(agent=init_agent2)
    SOURCE_HOST = 'compendium.ch'
    def init_agent2
      unless @agent
        @agent = Mechanize.new
        @agent.user_agent = 'Mozilla/5.0 (X11; Linux x86_64; rv:16.0) Gecko/20100101 Firefox/16.0'
        @agent.redirect_ok         = true
        @agent.redirection_limit   = 5
        @agent.follow_meta_refresh = true
        # entry point
        home = @agent.get("http://#{SOURCE_HOST}/default/Desktop/de"). \
          link_with(:href => /\/home\/prof\/de/).click
        form = home.form_with(:name => 'aspnetForm')
        button = form.button_with(:name => 'ctl00$MainContent$ibOptions')
        # behaves as click
        prng = Random.new(Time.new.to_i)
        button.x = prng.rand(5..55).to_s
        button.y = prng.rand(5..55).to_s
        @agent.pre_connect_hooks << lambda do |agent, request|
          agent.request_headers['Referer']    = "http://#{SOURCE_HOST}/home/prof/de"
          agent.request_headers['Connection'] = 'keep-alive'
          agent.request_headers['Host']       = SOURCE_HOST
          agent.request_headers['Cookie']     = @agent.cookies.join(';')
        end
        # discard this response
        form.click_button(button)
        # imitate setting of monographie search mode in "options", manualy
        option = @agent.get("http://#{SOURCE_HOST}/options/de")
        form = option.form_with(:name => 'aspnetForm')
        form.radiobutton_with(:id => 'ctl00_MainContent_rblMonographie_1').check # Fachinfo
        form.radiobutton_with(:id => 'ctl00_MainContent_rblCurrentLang_0').check # DE
        form.radiobutton_with(:id => 'ctl00_MainContent_rblContentLang_0').check # DE
        form.submit(form.button_with(:name => 'ctl00$MainContent$btnSave'))
        # overwrite cookie manualy for after request
        @agent.cookie_jar.each do |cookie|
          if cookie.name =~ /^dm\.kompendium/
            cookie.value.gsub!(/isTypeResultMonographieTitle=0/, 'isTypeResultMonographieTitle=1')
            cookie.value.gsub!(/language=EN/, 'language=DE')
          end
        end
      end
      @agent
    end
    def init_searchform2 agent=init_agent2
      url = ODDB.config.text_info_searchform2 \
        or raise 'please configure ODDB.config.text_info_searchform2 to proceed'
      agent.get(url)
    end
    def search2 term
      page = init_searchform2
      form = page.form_with(:name => 'aspnetForm')
      form['__EVENTTARGET']   = 'ctl00$MainContent$ucProductSearch1$rcbSearch'
      form['__EVENTARGUMENT'] = '{"Command":"TextChanged"}'
      form.field_with(:id => 'ctl00_MainContent_ucProductSearch1_ddlSearchType'). \
        value   = '1' # Product / Firma / Wirukstoffe
      form.field_with(:id => 'ctl00_MainContent_ucProductSearch1_rcbSearch_Input'). \
        value = term  # Text
      form.field_with(:id => 'ctl00_MainContent_ucProductSearch1_rcbSearch_ClientState').\
        value = '{' \
          '"logEntries":[],'       \
          '"value":"",'            \
          '"text":"' + term + '",' \
          '"enabled":true,'        \
          '"checkedIndices":[],'   \
          '"checkedItemsTextOverflows":false' \
        '}'
      @agent.pre_connect_hooks << lambda do |agent, request|
        agent.request_headers['Referer']       = ODDB.config.text_info_searchform2
        agent.request_headers['Content-Type']  = 'application/x-www-form-urlencoded; charset=utf-8'
        agent.request_headers['Host']          = SOURCE_HOST
        agent.request_headers['Pragma']        = 'no-cache'
        agent.request_headers['Cache-Control'] = 'no-cache'
      end
      list = []
      result = form.click_button
      result.links_with(:href => /\/mpro\/mnr\//) do |links|
        links.each do |link| # base is :fi
          if link.href =~ /\/(\d+)\/html/
            indx    = $1.to_s
            fi_name = link.text # de name
            _link = {}
            _link[:type] = :fi
            _link[:indx] = indx
            _link[:name] = fi_name
            list << _link
            if @target != :fi # :both or :pi
              if fi = link.click and
                 prod_link = fi.link_with(:id => /^ctl00_Tools_hlProductLink$/) and
                 prods = prod_link.click
                prods.links_with(
                  :id => /^ctl00_MainContent_ucProductSearch1_gvwProducts_ctl\d{2}_hlDetail1$/
                ).each do |link|
                  link.attributes['id'] =~ /^[0-9A-z_]*_ctl(\d{2})_[A-z0-9_]*$/
                  number = $1.to_s
                  if link.href =~ /\/prod\/pnr\/(\d+)\//
                    indx = $1.to_s
                    if prod = link.click and
                       prod.link_with(:href => /\/mpub\/pnr\/#{indx}\/html/) # if pi exists
                      pi_name = prods.at(
                        "//span[@id='ctl00_MainContent_ucProductSearch1_gvwProducts_ctl#{number}_lblDescr']"
                      )
                      _link = {}
                      _link[:type] = :pi
                      _link[:indx] = indx
                      _link[:name] = (pi_name ? pi_name.text : fi_name + "-#{indx}")
                      list << _link
                    end
                  end
                end
              end
            end
          end
        end
      end
      list
    end
    def search_company2(name)
      search2(name)
    end
    def download_info2(type, name, url)
      paths = {}
      flags = {}
      de, fr = nil
      @agent ||= init_agent2
      # de
      de = @agent.get(url + '/de')
      if match = /(Pseudo-Fach|Produkt)information/i.match(de.body)
        @ignored_pseudos += 1
        flags[:pseudo] = true
      end
      paths[:de] = save_info(type, name, :de, de, flags)
      # fr
      fr = @agent.get(url.to_s.gsub(/\/de$/, '/fr'))
      paths[:fr] = save_info(type, name, :fr, fr, flags)
      [paths, flags]
    rescue Mechanize::ResponseCodeError
      @download_errors << name
      [paths, flags]
    end
    def import_product2(type, name, url)
      url = url.to_s
      # use common update method :update_product
      case type
      when :fi, :fachinfo
        url = "http://#{SOURCE_HOST}/mpro/mnr/#{url}/html" if url =~ /^\d+$/
        paths, flags = download_info2(type, name, url)
        update_product(name, paths, {}, flags, {})
      when :pi, :patinfo
        url = "http://#{SOURCE_HOST}/mpub/pnr/#{url}/html" if url =~ /^\d+$/
        paths, flags = download_info2(type, name, url)
        update_product(name, {}, paths, {}, flags)
      end
    end
    ##
    # = import_product2
    #
    # ::Param
    #   * list = [
    #       {:type => :fi, :indx => '1234', :name => 'Fi-Name'},
    #       {:type => :pi, :indx => '1234', :name => 'Pi-Name'},
    #       ...
    #     ]
    def import_products2(list)
      case @target
      when :both
        list.each do |link|
          type = (link[:type] == :pi ? :patinfo : :fachinfo)
          import_product2(type, link[:name], link[:indx])
        end
      when :fi
        list.each do |link|
          next if link[:type] != :fi
          import_product2(:fachinfo, link[:name], link[:indx])
        end
      when :pi
        list.each do |link|
          next if link[:type] != :pi
          import_product2(:patinfo,  link[:name], link[:indx])
        end
      end
    end
    def textinfo_news2(agent=init_agent2)
      url = ODDB.config.text_info_newssource2 \
        or raise 'please configure ODDB.config.text_info_newssource2 to proceed'
      check_date = @options[:date] ? @options[:date] : Date.today
      # get security and innovation updates
      company_names = []
      tags = []
      updates = agent.get(url)
      tags += updates.search('//span[starts-with(@id, "ctl00_MainContent_UcNewsSecurity_dlNews_")]')
      tags += updates.search('//span[starts-with(@id, "ctl00_MainContent_ucInnovationNews_dlNews_")]')
      tags.map do |span|
        span['id'] =~ /_ctl(\d{2})_(Label1|lblDate)/ # date
        indx = ($1 ? $1.to_s : nil)
        type = ($2 == 'lblDate' ? 'innovation' : 'security')
        if (indx and type) and
           span.child.text =~ /\d{2}\.\d{2}\.\d{2}/
          begin
            date = Date.strptime(span.child.text, '%d.%m.%y')
          rescue ArgumentError
          end
          if date and date >= check_date
            id = case type
                 when 'security';   /ctl00_MainContent_UcNewsSecurity_dlNews_ctl#{indx}_hlDetailNews/
                 when 'innovation'; /ctl00_MainContent_ucInnovationNews_dlNews_ctl#{indx}_hlDetailNews/
                 end
            # Sometimes, innovation detail page does not have fi-Qulle link
            # We skip if it has only external links
            begin
              fi = updates.link_with(:id => id).click.
                  link_with(:href => /\/mpro\/mnr\//).click
            rescue NoMethodError
            end
            if fi and
               chapter = fi.at("//a[@name='7850']") and
               name = chapter.parent.parent.at('.//p').text # first p
              company_names << name.split(',').first if name
            end
          end
        end
      end
      company_names.uniq
    end
    def import_company2(name, target=:both, agent=init_agent2)
      if name.is_a?(Array) # for consistency againt old interface
        import_companies2(name, target, agent)
      else
        @new_format_flag = true
        @target = target
        @search_term << name
        @companies << name
        @current_search = [:search_company, name]
        list = search_company2(name)
        import_products2(list)
      end
    end
    def import_companies2(company_names, target=:both, agent=init_agent2)
      company_names.to_a.each do |name|
        import_company2(name, target, agent)
      end
    end
    def import_news2(target=:both, agent=init_agent2)
      updated = []
      company_names = textinfo_news2(agent)
      import_companies2(company_names, target, agent)
      postprocess
    end
  end
end
