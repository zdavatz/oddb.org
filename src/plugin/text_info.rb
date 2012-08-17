#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TextInfoPlugin -- oddb.org -- 17.08.2012 -- yasaka@ywesee.com
# ODDB::TextInfoPlugin -- oddb.org -- 30.01.2012 -- mhatakeyama@ywesee.com 
# ODDB::TextInfoPlugin -- oddb.org -- 17.05.2010 -- hwyss@ywesee.com 

require 'config'
require 'plugin/plugin'
require 'drb'
require 'mechanize'
require 'model/fachinfo'
require 'model/patinfo'
require 'view/rss/fachinfo'
require 'fileutils'

class Mechanize 
  TOP_URL = ODDB.config.text_info_searchform2

  FORM_ID = 'aspnetForm'

  FI_HOME_BUTTON_ID = 'ctl00_MainContent_btnProUser'
  PI_HOME_BUTTON_ID = 'ctl00_MainContent_btnPubUser'

  FI_SELECT_ID = 'ctl00_MainContent_ddlSearchType'

  SEARCH_HOME_BUTTON_ID = 'ctl00_MainContent_ibSearch'
  SEARCH_BUTTON_ID = 'ctl00_MainContent_ibSearch'

  PI_SEARCH_FIELD_ID = 'ctl00_MainContent_txtSearch'
  FI_SEARCH_FIELD_ID = 'ctl00_MainContent_rcbSearch_ClientState' # hidden text 

  FI_PRODUCT_TABLE_ID = 'ctl00_MainContent_gvwProducts'
  PI_PRODUCT_TABLE_ID = 'ctl00_MainContent_ucProd_dlProducts'
  def top_page
    get(TOP_URL)
  end
  def search_page(type = 'FI'||'PI', lang)
    page = top_page
    form = page.form_with(:id => FORM_ID)
    if lang == 'FR'
      radio = page.at('input[@value="FR"]')
      event = arg = nil
      if attr = radio.attributes['onclick'] and val = attr.value \
        and match = val.match(/__doPostBack\(\\'(.*)\\',\\'(.*)\\'/) \
        and match.length == 3
        event = match[1]
        arg   = match[2]
        radio = form.radiobutton_with(:value => lang)
        radio.check
        page = page.emulate_doPostBack(event, arg)
      end
    end
    page.search_page(type, lang)
  end
  def search_fachinfo(search_word, lang='DE'||'FR')
    page = search_page('FI', lang.upcase)
    pages = page.search_fachinfo(search_word)
  end
  def search_patinfo(search_word, lang='DE'||'FR')
    page = search_page('PI', lang.upcase)
    pages = page.search_patinfo(search_word)
  end

  class Page 
    attr_accessor :lang
    attr_accessor :info_type
    attr_reader :up_to_date, :pseudo
    def next_page(button_id)
      form = form_with(:id => FORM_ID)
      button = form.button_with(:id => button_id)
      page = form.click_button(button)
      page.lang = lang
      page
    end
    def search_page(type, lang)
      @info_type = type
      @lang = lang
      button_id = eval(type + '_HOME_BUTTON_ID')
      page = next_page(button_id)
      page = page.next_page(SEARCH_HOME_BUTTON_ID)
      page.lang = @lang
      page.info_type = @info_type
      page
    end
    def emulate_doPostBack(event, arg)
      form = form_with(:name => FORM_ID)
      form.field_with(:id => '__EVENTTARGET').value = event
      form.field_with(:id => '__EVENTARGUMENT').value = arg
      page = form.submit
      page.lang = lang
      page.info_type = info_type
      page
    end
    attr_accessor :file_name
    def fachinfo_pages
      form = form_with(:name => FORM_ID)
      buttons = form.buttons
      buttons.shift # the first button is the search button
      pages = []
      buttons.each do |button|
        page = form.click_button(button)
        page.lang = lang
        page.info_type = info_type
        if mon_title = page.at('div.MonTitle')
          page.file_name = mon_title.text
        end
        pages << page
      end
      pages 
    end
    def search_fachinfo(search_word)
      # get result page (fachinfo list)
      form = form_with(:name => FORM_ID)
      select = form.field_with(:id => FI_SELECT_ID)
      select.option_with(:value => '1').select
      input = form.field_with(:id => FI_SEARCH_FIELD_ID)
      input.value = '{"logEntries":[],"value":"","text":"' + search_word + '","enabled":true,"checkedIndices":[],"checkedItemsTextOverflows":false}'
      button = form.button_with(:id => SEARCH_BUTTON_ID)
      page = form.click_button(button)
      page.lang = lang
      page.info_type = info_type

      # gather fachinfo document (html) list
      pages = page.fachinfo_pages
    end
    def patinfo_pages
      table = self.at("table[@id='#{PI_PRODUCT_TABLE_ID}']")
      pi_list = table.search("a")
      event_arg_list = []
      pi_list.each do |pi|
        if attr = pi.attributes['href'] and match = attr.value.match(/'(.*)','(.*)'/)\
          and match.length == 3
          event_arg_list << [match[1], match[2]]
        end
      end
      event_arg_list.uniq!

      pages = []
      event_arg_list.each do |event, arg|
        page = emulate_doPostBack(event,arg)
        page.lang = lang
        page.info_type = info_type
        if mon_title = page.at('div.MonTitle')
          page.file_name = mon_title.text 
        end
        pages << page
      end
      pages
    end
    def search_patinfo(search_word)
      # get result page (patinfo list)
      form = form_with(:name => FORM_ID)
      input = form.field_with(:id => PI_SEARCH_FIELD_ID)
      input.value = search_word
      button = form.button_with(:id => SEARCH_BUTTON_ID)
      page = form.click_button(button)
      page.lang = lang
      page.info_type = info_type

      # gather patinfo document (html) list
      pages = page.patinfo_pages
    end
    def save_body
      if @file_name
        dirs = {
          'FI' => ::File.join(ODDB.config.data_dir, 'html', 'fachinfo'),
          'PI' => ::File.join(ODDB.config.data_dir, 'html', 'patinfo'),
        }
        dir = ::File.join dirs[info_type], lang.downcase.to_s
        FileUtils.mkdir_p dir
        tmp = ::File.join dir, @file_name.gsub(/[\/\s\+:]/, '_') + '.tmp.html'
        open(tmp, "w") do |out|
          out.print body
        end
        if /(Pseudo-Fach|Produkt)information/i.match(body)
          @pseudo = true
        end
        path = ::File.join dir, @file_name.gsub(/[\/\s\+:]/, '_') + '.html'
        if ::File.exist?(path) && FileUtils.compare_file(tmp, path)
          @up_to_date = true
        end
        FileUtils.mv tmp, path
        path
      end
    end
    def print_body(file_name='test.html')
      open(file_name,"w") do |out|
        out.print self.body
      end
    end
  end
end

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
      @iksless = []
      @unknown_iksnrs = {}
      @failures = []
      @download_errors = []
      @companies = []
      @news_log = File.join ODDB.config.log_dir, 'textinfos.txt'
      @new_format_flag = false
      @target = :both
    end
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
    def identify_eventtargets page, ptrn
      eventtargets = {}
      page.links_with(:href => ptrn).each do |link|
        eventtargets.store link.text, eventtarget(link.href)
      end
      eventtargets
    end
    def import_company names, agent=nil, target=:both
      @target = target
      agent = init_agent if agent.nil?
      @search_term = names.to_a.join ', '
      names.to_a.each do |name|
        @current_search = [:search_company, name]
        # search for company
        page = search_company name, agent
        # import each company from the result
        import_companies page, agent, target
      end
    end
    def import_company2 names, agent=init_agent
      @new_format_flag = true
      @search_term = names.to_a.join ', '
      downloaded_files = {}
      list = {}
      fi_de_name_uptodate = {}
      fi_fr_name_uptodate = {}
      fi_de_name_pseudo   = {}
      pi_de_name_uptodate = {}
      pi_fr_name_uptodate = {}
      names.delete('')

      #
      # search and download files
      #
      names.to_a.each do |name|
        @current_search = [:search_company, name]
        ## fachinfo
        # de
        agent = init_agent
        pages = agent.search_fachinfo(name, 'DE')
        file_names = pages.map{|page| page.file_name}.compact.uniq
        file_names.each_with_index do |file_name, i|
          page = pages.find{|page| page.file_name == file_name}
          if path = page.save_body
            downloaded_files[:fi] ||= {}
            downloaded_files[:fi][:de] ||= []
            downloaded_files[:fi][:de] << path
          end
          if page.up_to_date
            fi_de_name_uptodate.store(file_name.gsub(/[\/\s\+:]/, '_'), true)
          end
          if page.pseudo
            fi_de_name_pseudo.store(file_name.gsub(/[\/\s\+:]/, '_'), true)
          end
        end

        # fr
        agent = init_agent
        pages = agent.search_fachinfo(name, 'FR')
        file_names = pages.map{|page| page.file_name}.compact.uniq
        file_names.each_with_index do |file_name, i|
          page = pages.find{|page| page.file_name == file_name}
          if path = page.save_body
            downloaded_files[:fi] ||= {}
            downloaded_files[:fi][:fr] ||= []
            downloaded_files[:fi][:fr] << path
          end
          if page.up_to_date
            fi_fr_name_uptodate.store(file_name.gsub(/[\/\s\+:]/, '_'), true)
          end
        end

        ## patinfo
        # de
        agent = init_agent
        pages = agent.search_patinfo(name, 'DE')
        file_names = pages.map{|page| page.file_name}.compact.uniq
        file_names.each_with_index do |file_name, i|
          page = pages.find{|page| page.file_name == file_name}
          if path = page.save_body
            downloaded_files[:pi] ||= {}
            downloaded_files[:pi][:de] ||= []
            downloaded_files[:pi][:de] << path
          end
          if page.up_to_date
            pi_de_name_uptodate.store(file_name.gsub(/[\/\s\+:]/, '_'), true)
          end
        end

        # fr
        agent = init_agent
        pages = agent.search_patinfo(name, 'FR')
        file_names = pages.map{|page| page.file_name}.compact.uniq
        file_names.each_with_index do |file_name, i|
          page = pages.find{|page| page.file_name == file_name}
          if path = page.save_body
            downloaded_files[:pi] ||= {}
            downloaded_files[:pi][:fr] ||= []
            downloaded_files[:pi][:fr] << path
          end
          if page.up_to_date
            pi_fr_name_uptodate.store(file_name.gsub(/[\/\s\+:]/, '_'), true)
          end
        end
      end

      #
      # parse all the downloaded files and check iksnr
      # and store up_to_date flag
      #
      # fi de
      fi_de_iksnr_path = {}
      fi_de_name_iksnr = {}
      fi_de_iksnr_name = {}
      if downloaded_files[:fi] and downloaded_files[:fi][:de]
        downloaded_files[:fi][:de].each do |path|
          iksnr = if match = parse_fachinfo(path).iksnrs.to_s.match(/(\d{5})/)
                    match[1]
                  end
          if iksnr
            fi_de_iksnr_path.store(iksnr, path)
            fi_de_name_iksnr.store(File.basename(path).gsub(/\.html/,''), iksnr)
            fi_de_iksnr_name.store(iksnr, File.basename(path).gsub(/\.html/,''))
          end
        end
      end

      # fi fr
      fi_fr_iksnr_path = {}
      if downloaded_files[:fi] and downloaded_files[:fi][:fr]
        downloaded_files[:fi][:fr].each do |path|
          iksnr = if match = parse_fachinfo(path).iksnrs.to_s.match(/(\d{5})/)
                    match[1]
                  end
          if iksnr
            fi_fr_iksnr_path.store(iksnr, path)
            if flag = fi_fr_name_uptodate[File.basename(path).gsub(/\.html/,'')]
              if de_name = fi_de_iksnr_name[iksnr]
                fi_fr_name_uptodate.store(de_name, flag)
              end
            end
          end
        end
      end

      # pi de
      pi_de_iksnr_path = {}
      if downloaded_files[:pi] and downloaded_files[:pi][:de]
        downloaded_files[:pi][:de].each do |path|
          iksnr = if match = parse_patinfo(path).iksnrs.to_s.match(/(\d{5})/)
                    match[1]
                  end

          if iksnr
            pi_de_iksnr_path.store(iksnr, path)
             if flag = pi_de_name_uptodate[File.basename(path).gsub(/\.html/,'')]
              if de_name = fi_de_iksnr_name[iksnr]
                pi_de_name_uptodate.store(de_name, flag)
              end
            end
          end
        end
      end
     
      # pi fr
      pi_fr_iksnr_path = {}
      if downloaded_files[:pi] and downloaded_files[:pi][:fr]
        downloaded_files[:pi][:fr].each do |path|
          iksnr = if match = parse_patinfo(path).iksnrs.to_s.match(/(\d{5})/)
                    match[1]
                  end
          if iksnr
            pi_fr_iksnr_path.store(iksnr, path)
            if flag = pi_fr_name_uptodate[File.basename(path).gsub(/\.html/,'')]
              if de_name = fi_de_iksnr_name[iksnr]
                pi_fr_name_uptodate.store(de_name, flag)
              end
            end
          end
        end
      end

      #
      # store list for update_product
      #
      fi_de_name_iksnr.each do |name, iksnr|
        # de
        list[name] ||= {}
        list[name][:fi] ||= {}
        list[name][:fi].store(:de, fi_de_iksnr_path[iksnr])
        if pi_path = pi_de_iksnr_path[iksnr]
          list[name][:pi] ||= {}
          list[name][:pi].store(:de, pi_path)
        end


        # fr
        if fi_path = fi_fr_iksnr_path[iksnr]
          list[name][:fi].store(:fr, fi_path)
        end
        if pi_path = pi_fr_iksnr_path[iksnr]
          list[name][:pi] ||= {}
          list[name][:pi].store(:fr, pi_path)
        end
      end

      #
      # update_product
      #
      list.each do |name, path_list|
        fi_flag = {}
        pi_flag = {}
        fi_flag.store(:de, fi_de_name_uptodate[name])
        fi_flag.store(:fr, fi_fr_name_uptodate[name])
        fi_flag.store(:pseudo, fi_de_name_pseudo[name])
        pi_flag.store(:de, pi_de_name_uptodate[name])
        pi_flag.store(:fr, pi_fr_name_uptodate[name])
        update_product name, path_list[:fi]||{}, path_list[:pi]||{}, fi_flag, pi_flag
      end
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
    def import_fulltext terms, agent=init_agent
      @search_term = terms.to_a.join ', '
      terms.to_a.each do |term|
        @current_search = [:search_fulltext, term]
        page = search_fulltext term, agent
        import_products page, agent
      end
    end
    def import_name terms, agent=init_agent
      @search_term = terms.to_a.join ', '
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
    def log_news lines
      FileUtils.mkdir_p(File.dirname(@news_log))
      File.open(@news_log, 'w') do |fh|
        fh.print lines.join("\n")
      end
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
    def parse_fachinfo path
      @parser.parse_fachinfo_html(path, @new_format_flag)
    end
    def parse_patinfo path
      @parser.parse_patinfo_html(path, @new_format_flag)
    end
    def postprocess
      update_rss_feeds('fachinfo.rss', @app.sorted_fachinfos, View::Rss::Fachinfo)
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
    def replace text_info, container, type
      old_ti = container.send type
      @app.update container.pointer, type => text_info.pointer
      if old_ti && old_ti.empty?
        @app.delete old_ti.pointer
      end
    end
    def report
      unknown_size = @unknown_iksnrs.size
      unknown = @unknown_iksnrs.collect { |iksnr, name|
        "#{name} (#{iksnr})"
      }.join("\n")
      if @target == :pi
        [
          "Searched for #{@search_term}",
          "Stored #{@updated_pis} Patinfos",
          "Ignored #{@up_to_date_pis} up-to-date Patinfo-Texts", nil,
          "Checked #{@companies.size} companies",
          @companies.join("\n"), nil,
          "Unknown Iks-Numbers: #{unknown_size}",
          unknown, nil,
          "Session failures: #{@session_failures}", nil,
          "Download errors: #{@download_errors.size}",
          @download_errors.join("\n"), nil,
          "Parse Errors: #{@failures.size}",
          @failures.join("\n"),
        ].join("\n")
      else
        [
          "Searched for #{@search_term}",
          "Stored #{@updated_fis} Fachinfos",
          "Ignored #{@ignored_pseudos} Pseudo-Fachinfos",
          "Ignored #{@up_to_date_fis} up-to-date Fachinfo-Texts",
          "Stored #{@updated_pis} Patinfos",
          "Ignored #{@up_to_date_pis} up-to-date Patinfo-Texts", nil,
          "Checked #{@companies.size} companies",
          @companies.join("\n"), nil,
          "Unknown Iks-Numbers: #{unknown_size}",
          unknown, nil,
          "Fachinfos without iksnrs: #{@iksless.size}",
          @iksless.join("\n"), nil,
          "Session failures: #{@session_failures}", nil,
          "Download errors: #{@download_errors.size}",
          @download_errors.join("\n"), nil,
          "Parse Errors: #{@failures.size}", 
          @failures.join("\n"), 
        ].join("\n")
      end
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
      page.images_with(:src => %r!data/pictures/!).each do |image|
        filename = File.basename(image.src.strip)
        img_file = File.join dir, name_base + '_files', filename
        image.fetch.save img_file
        FileUtils.cp img_file, File.join(resource_dir, filename)
      end
      path
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
    def search_company name, agent
      search 'rbFirma', name, agent
    end
    def search_fulltext term, agent
      search 'rbFulltext', term, agent
    end
    def search_product name, agent
      search 'rbPraeparat', name, agent
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
    def true_news news, old_news
      news - old_news
    end
    def update_product name, fi_paths, pi_paths, fi_flags={}, pi_flags={}
      #p "name = #{name}, fi_paths = #{fi_paths}, pi_paths = #{pi_paths}, fi_flags = #{fi_flags}, pi_flags = #{pi_flags}"
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
    def update_fachinfo name, fis, fi_flags
      begin
        # identify registration
        iksnrs = extract_iksnrs fis
        if iksnrs.empty?
          @iksless.push name
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
            store_orphaned iksnr, fis, :orphaned_fachindo
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
          @iksless.push name
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
  end
end
