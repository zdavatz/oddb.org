require 'config'
require 'plugin/plugin'
require 'drb'
require 'mechanize'
require 'model/fachinfo'
require 'model/patinfo'
require 'view/rss/fachinfo'

module ODDB
  class TextInfoPlugin < Plugin
    def initialize *args
      super
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
      @news_log = File.join ODDB.config.log_dir, 'fachinfo.txt'
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
    def fachinfo_news agent=init_agent
      url = ODDB.config.text_info_newssource \
        or raise 'please configure ODDB.config.text_info_newssource to proceed'
      fi_ptrn = /Monographie.aspx\?Id=([0-9A-Fa-f\-]{36}).*MonType=fi/u
      ids = []
      page = agent.get url
      page.links.each do |link|
        if match = fi_ptrn.match(link.href)
          ids.push [match[1], link.text.gsub(/;$/, '')]
        end
      end
      ids
    end
    def identify_eventtargets page, ptrn
      eventtargets = {}
      page.links_with(:href => ptrn).each do |link|
        eventtargets.store link.text, eventtarget(link.href)
      end
      eventtargets
    end
    def import_company names, agent=init_agent
      @search_term = names.to_a.join ', '
      names.to_a.each do |name|
        @current_search = [:search_company, name]
        # search for company
        page = search_company name, agent
        # import each company from the result
        import_companies page, agent
      end
    end
    def import_companies page, agent
      form = page.form_with :name => 'frmResulthForm'
      page.links_with(:href => /Linkbutton1/).each do |link|
        if et = eventtarget(link.href)
          @companies.push link.text
          @current_eventtarget = et
          products = submit_event agent, form, et
          import_products products, agent
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
      old_news = old_fachinfo_news
      updates = true_news fachinfo_news(agent), old_news
      updates.reverse!
      indices, names = updates.transpose
      if names
        import_name names, agent
        log_news updates + old_news
        postprocess
      end
      !updates.empty?
    end
    def import_products page, agent
      fi_sources = identify_eventtargets page, /dtgFachinfo/
      pi_sources = identify_eventtargets page, /dtgPatienteninfo/
      form = page.form_with :name => /frmResult(Produkte|hForm)/
      fi_sources.sort.each do |name, eventtarget|
        import_product name, agent, form, eventtarget, pi_sources[name]
      end
    end
    def import_product name, agent, form, fi_target, pi_target
      fi_paths, fi_flags = download_info :fachinfo, name, agent, form, fi_target
      if pi_target
        pi_paths, pi_flags = download_info :patinfo, name, agent, form, pi_target
      end
      update_product name, fi_paths, pi_paths || {}, fi_flags, pi_flags || {}
    end
    def log_news lines
      File.open @news_log, 'w' do |fh|
        lines.each do |pair|
          fh.puts pair.join(' ')
        end
      end
    end
    def old_fachinfo_news
      begin
        File.readlines(@news_log).collect do |line|
          line.strip.split ' ', 2
        end
      rescue Errno::ENOENT
        []
      end
    end
    def parse_fachinfo path
      @parser.parse_fachinfo_html path
    end
    def parse_patinfo path
      @parser.parse_patinfo_html path
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
    def save_info type, name, lang, page, flags={}
      dir = File.join @dirs[type], lang.to_s
      FileUtils.mkdir_p dir
      tmp = File.join dir, name.gsub(/[\/\s\+:]/, '_') + '.tmp.html'
      page.save tmp
      path = File.join dir, name.gsub(/[\/\s\+:]/, '_') + '.html'
      if File.exist?(path) && FileUtils.compare_file(tmp, path)
        flags.store lang, :up_to_date
      end
      FileUtils.mv tmp, path
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
    def store_orphaned iksnr, fis, pis
      pointer = Persistence::Pointer.new :orphaned_fachinfo
      store = {
        :key => iksnr,
        :languages => fis,
      }
      @app.update pointer.creator, store
      pointer = Persistence::Pointer.new :orphaned_patinfo
      store = {
        :key => iksnr,
        :languages => pis,
      }
      @app.update pointer.creator, store
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
      if (pair = old_news.first) && idx = news.flatten.index(pair.first)
        news[0...idx/2]
      else
        news
      end
    end
    def update_product name, fi_paths, pi_paths, fi_flags={}, pi_flags={}
      # parse pi and fi
      fis = {}
      fi_paths.each do |lang, path|
        fis.store lang, parse_fachinfo(path)
      end
      pis = {}
      ## there's no need to parse up-to-date patinfos
      #  if both of them are up-to-date
      if pi_flags[:de] && pi_flags[:fr]
        pi_paths.clear
        @up_to_date_pis += 1
      end
      pi_paths.each do |lang, path|
        pis.store lang, parse_patinfo(path)
      end
      unless fis.empty?
        # identify registration
        iksnrs = extract_iksnrs fis
        if iksnrs.empty?
          @iksless.push name
        end
        ## Now that we have identified the pertinent iksnrs, we can remove
        #  up-to-date fachinfos from the queue.
        if fi_flags[:de] && fi_flags[:fr]
          fis.clear
          @up_to_date_fis += 1
        end
        fachinfo, patinfo = nil
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
            unless pis.empty?
              patinfo ||= store_patinfo(reg, pis)
              reg.each_sequence do |seq|
                replace patinfo, seq, :patinfo
              end
            end
          else
            store_orphaned iksnr, fis, pis
            @unknown_iksnrs.store iksnr, name
          end
        end
      end
    rescue RuntimeError => err
      @failures.push err.message
    end
  end
end
