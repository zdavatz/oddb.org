#!/usr/bin/env ruby

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'yaml'
YAML::ENGINE.yamler = "syck"
require 'active_support/core_ext/class/attribute_accessors'
require 'odba'
require 'util/failsafe'
require 'sbsm/drbserver'
require 'sbsm/index'
require 'util/persistence'
require 'util/session'
require 'model/atcclass'
require 'model/galenicgroup'
require 'model/substance'

  class OddbPrevalence
  include ODDB::Failsafe
  include ODBA::Persistable
  RESULT_SIZE_LIMIT = 250
  ODBA_EXCLUDE_VARS = [
    "@atc_chooser", "@bean_counter", "@sorted_fachinfos", "@sorted_feedbacks",
    "@sorted_minifis",
  ]
  ODBA_SERIALIZABLE = [ '@currency_rates', '@rss_updates' ]
  attr_reader :address_suggestions, :atc_chooser, :atc_classes,
    :companies, :divisions, :doctors, :epha_interactions, :experiences, :fachinfos, 
    :galenic_groups, :hospitals, :invoices, :last_medication_update, :last_update,
    :minifis, :notification_logger, :orphaned_fachinfos,
    :orphaned_patinfos, :patinfos, :patinfos_deprived_sequences,
    :registrations, :slates, :users, :narcotics, :accepted_orphans,
    :commercial_forms, :rss_updates, :feedbacks, :indices_therapeutici,
    :generic_groups, :shorten_paths
  def initialize
    init
    @last_medication_update ||= Time.now()
  end
  def init
    create_unknown_galenic_group()
  end
  # prevalence-methods ################################
  def create(pointer)
    @last_update = Time.now()
    failsafe {
      if(item = pointer.issue_create(self))
        updated(item)
        item
      end
    }
  end
  def galenic_form(name)
    @galenic_groups.values.collect { |galenic_group|
      galenic_group.get_galenic_form(name)
    }.compact.first
  end
  def galenic_group(oid)
    @galenic_groups[oid.to_i]
  end
  def create_galenic_group
    galenic_group = ODDB::GalenicGroup.new
    @galenic_groups.store(galenic_group.oid, galenic_group)
  end
  def updated(item)
  end
# private
  def create_unknown_galenic_group
    unless(@galenic_groups.is_a?(Hash) && @galenic_groups.size > 0)
      @galenic_groups = []
      @galenic_forms = []
      groups = File.expand_path(File.join(__FILE__, '..', '..', '..', 'test', 'integration', 'data', 'galenic_groups.yaml'))
      puts groups
      forms = File.expand_path(File.join(__FILE__, '..', '..', '..', 'test', 'integration', 'data', 'galenic_forms.yaml'))
      puts forms
      @galenic_groups = YAML.load_file(groups)
#      require 'pry'; binding.pry
      puts "After loading #{groups} @galenic_groups #{@galenic_groups.inspect}"
      return
      puts "After loading #{groups} have #{@galenic_groups.size} galenic groups"
      @galenic_forms = YAML.load_file(forms)
      puts "After loading #{forms} have #{@galenic_forms.size} galenic forms"
    end
  end
end

module ODDB
  class App < SBSM::DRbServer
    include Failsafe
    AUTOSNAPSHOT = true
    CLEANING_INTERVAL = 5*60
    EXPORT_HOUR = 2
    UPDATE_HOUR = 9
    MEMORY_LIMIT = 7*1024 # 7 GB # 5 are normally enough, but running unit tests needs between 6 and 7 GB
    MEMORY_LIMIT_CRAWLER = 1450 # 1,4 GB
    RUN_CLEANER = true
    RUN_UPDATER = false
    SESSION = Session
    UNKNOWN_USER = UnknownUser
    UPDATE_INTERVAL = 24*60*60
    VALIDATOR = Validator
    YUS_SERVER = DRb::DRbObject.new(nil, YUS_URI)
    MIGEL_SERVER = DRb::DRbObject.new(nil, MIGEL_URI)
    attr_reader :cleaner, :updater
    def initialize opts={}
      puts "initialize "
      puts caller
      OddbPrevalence.new
      puts "early exit "
      exit 3

      if opts.has_key?(:process)
        @process = opts[:process]
      else
        @process = :user
      end
      puts "process: #{$0}"
      @rss_mutex = Mutex.new
      @admin_threads = ThreadGroup.new
      start = Time.now
      @system = ODBA.cache.fetch_named('oddbapp', self){
        OddbPrevalence.new
      }
      puts "init system"
      @system.init
      @system.odba_store
      puts "init system: #{Time.now - start}"
      puts "setup drb-delegation"
      super(@system)
      return if opts[:auxiliary]
      puts "reset"
      reset()
      puts "reset: #{Time.now - start}"
      log_size
      puts "system initialized"
      puts "initialized: #{Time.now - start}"
    end
    # prevalence-methods ################################
    def accept_orphaned(orphan, pointer, symbol, origin=nil)
      command = AcceptOrphan.new(orphan, pointer,symbol, origin)
      @system.execute_command(command)
    end
    def clean
      super
      @system.clean_invoices
    end
    def create(pointer)
      @system.execute_command(CreateCommand.new(pointer))
    end
    def create_commercial_forms
      @system.each_package { |pac| 
        if(comform = pac.comform)
          possibilities = [
            comform.strip,
            comform.gsub(/\([^\)]+\)/u, '').strip,
            comform.gsub(/[()]/u, '').strip,
          ].uniq.delete_if { |possibility| possibility.empty? }
          cform = nil
          possibilities.each { |possibility|
            if(cform = CommercialForm.find_by_name(possibility))
              break
            end
          }
          if(cform.nil?)
            args = { :de => possibilities.first, 
              :synonyms => possibilities[1..-1] }
            possibilities.each { |possibility|
              if(form = @system.galenic_form(possibility))
                args = form.descriptions
                args.store(:synonyms, form.synonyms)
                break
              end
            }
            pointer = Persistence::Pointer.new(:commercial_form)
            cform = @system.update(pointer.creator, args)
          end
          pac.commercial_form = cform
          pac.odba_store
        end
      }
    end
    def delete(pointer)
      @system.execute_command(DeleteCommand.new(pointer))
    end
    def inject_poweruser(email, pass, days)
      user_pointer = Persistence::Pointer.new(:poweruser)
      user_data = {
        :unique_email => email,
        :pass_hash    => Digest::MD5.hexdigest(pass),
      }
      invoice_pointer = Persistence::Pointer.new(:invoice)
      time = Time.now
      expiry = InvoiceItem.expiry_time(days, time)
      invoice_data = { :currency => State::PayPal::Checkout::CURRENCY }
      item_data = {
        :duration     => days,
        :expiry_time  => expiry,
        :total_netto  => State::Limit.price(days.to_i),
        :quantity     => days,
        :text         => 'unlimited access',
        :time         => time,
        :type         => :poweruser,
        :vat_rate     => VAT_RATE,
      }
      user = @system.update(user_pointer.creator, user_data, :admin)
      invoice = @system.update(invoice_pointer.creator, invoice_data, :admin)
      item_pointer = invoice.pointer + [:item]
      @system.update(item_pointer.creator, item_data, :admin)
      user.add_invoice(invoice)
      invoice.payment_received!
      invoice.odba_isolated_store
    end
    def merge_commercial_forms(source, target)
      command = MergeCommand.new(source.pointer, target.pointer)
      @system.execute_command(command)
    end
    def merge_companies(source_pointer, target_pointer)
      command = MergeCommand.new(source_pointer, target_pointer)
      @system.execute_command(command)
    end
    def merge_galenic_forms(source, target)
      command = MergeCommand.new(source.pointer, target.pointer)
      @system.execute_command(command)
    end
    def merge_indications(source, target)
      command = MergeCommand.new(source.pointer, target.pointer)
      @system.execute_command(command)
    end
    def merge_substances(source_pointer, target_pointer)
      command = MergeCommand.new(source_pointer, target_pointer)
      @system.execute_command(command)
    end
    def replace_fachinfo(iksnr, pointer)
      @system.execute_command(ReplaceFachinfoCommand.new(iksnr, pointer))
    end
    def update(pointer, values, origin=nil)
      @system.update(pointer, values, origin)
    end
    def set_all_export_flag_registration(boolean)
      data = {:export_flag => boolean}
      @system.each_registration do |reg|
        update reg.pointer, data, :swissmedic
      end
    end
    def set_all_export_flag_sequence(boolean)
      data = {:export_flag => boolean}
      @system.each_sequence do |seq|
        update seq.pointer, data, :swissmedic
      end
    end
    #####################################################
    def _admin(src, result, priority=0)
      t = Thread.new {
        Thread.current.abort_on_exception = false
        result << failsafe {
          response = instance_eval(src)
          str = response.to_s
          if(str.length > 200)
            response.class
          else
            str
          end
        }.to_s
      }
      t[:source] = src
      t.priority = priority
      @admin_threads.add(t)
      t
    end
    def login(email, pass)
      YusUser.new(YUS_SERVER.login(email, pass, YUS_DOMAIN))
    end
    def login_token(email, token)
      YusUser.new(YUS_SERVER.login_token(email, token, YUS_DOMAIN))
    end
    def logout(session)
      YUS_SERVER.logout(session)
    rescue DRb::DRbError, RangeError
    end
    def peer_cache cache
      ODBA.peer cache
    end
    def reset
      @random_updater.kill if(@random_updater.is_a? Thread)
      if RUN_UPDATER and @process == :user
        @random_updater = run_random_updater
      end
      @mutex.synchronize {
        @sessions.clear
      }
    end
    def run_random_updater
      Thread.new {
        Thread.current.abort_on_exception = true
        update_hour = rand(24)
        update_min = rand(60)
        day = (update_hour > Time.now.hour) ? \
          today : today.next
        loop {
          next_run = Time.local(day.year, day.month, day.day,
            update_hour, update_min)
          puts "next random update will take place at #{next_run}"
          $stdout.flush
          sleep(next_run - Time.now)
          Updater.new(self).run_random
          @system.recount
          GC.start
          day = today.next
          update_hour = rand(24)
          update_min = rand(60)
        }
      }
    end
    def unpeer_cache cache
      ODBA.unpeer cache
    end
    def update_feedback_rss_feed
      async {
        begin
        @rss_mutex.synchronize {
          values = @system.sorted_feedbacks
          values.select! do |feedback|
            feedback.item.is_a?(ODDB::Package) if feedback.item
          end
          values.each do |feedback|
            if feedback.item.name
              feedback.item.name.force_encoding('utf-8')
            end
            if feedback.item.respond_to?(:size) and feedback.item.size
              feedback.item.size.force_encoding('utf-8')
            end
            feedback.name.force_encoding('utf-8') if feedback.name
            feedback.email.force_encoding('utf-8') if feedback.email
            feedback.message.force_encoding('utf-8') if feedback.message
          end
          plg = Plugin.new(self)
          plg.update_rss_feeds('feedback.rss', values, View::Rss::Feedback)
        }
        rescue StandardError => e
          puts e.message
          puts e.backtrace
        end
      }
    end

    def ipn(notification)
      Util::Ipn.process notification, self
      nil # don't return the invoice back across drb - it's not defined in yipn
    end
    def grant_download(email, filename, price, expires=Time.now+2592000)
      ip = Persistence::Pointer.new(:invoice)
      inv = update ip.creator, :yus_name => email, :currency => 'EUR'
      itp = inv.pointer + :item
      update itp.creator, :text => filename, :price => price, :time => Time.now,
                          :type => :download, :expiry_time => expires,
                          :duration => (Time.now - expires) / 86400,
                          :vat_rate => 8.0
      inv.payment_received!
      inv.odba_store
      "http://#{SERVER_NAME}/de/gcc/download/invoice/#{inv.oid}/email/#{email}/filename/#{filename}"
    end

    def assign_effective_forms(arg=nil)
      _assign_effective_forms(arg)
    end
    def _assign_effective_forms(arg=nil)
      result = nil
      last = nil
      @system.substances.select { |subs| 
        !subs.has_effective_form? && (arg.nil? || arg.to_s < subs.to_s)
      }.sort_by { |subs| subs.name }.each { |subs|
        puts "Looking for effective form of ->#{subs}<- (#{subs.sequences.size} Sequences)"
        name = subs.to_s
        parts = name.split(/\s/u)
        suggest = if(parts.size == 1)
          subs
        elsif(![nil, '', 'Acidum'].include?(parts.first))
          @system.search_single_substance(parts.first) \
            || @system.search_single_substance(parts.first.gsub(/i$/u, 'um'))
        end
        last = result
        result = nil
        while(result.nil?)
          possibles = [
            "d(elete)", 
            "S(elf)", 
            "n(othing)", 
            "other_name",
          ]
          if(suggest)
            puts "Suggestion:                   ->#{suggest}<-"
            possibles.unshift("s(uggestion)")
          end
          if(last)
            puts "Last:                         ->#{last}<-"
            possibles.unshift("l(ast)")
          end
          print possibles.join(", ")
          print " > "
          $stdout.flush
          answer = $stdin.readline.strip
          puts "you typed:                    ->#{answer}<-"
          case answer
          when ''
            # do nothing
          when 'l'
            result = last
          when 's'
            result = suggest
          when 'S'
            result = subs
          when 'd'
            subs.sequences.each { |seq| 
              seq.delete_active_agent(subs) 
              seq.active_agents.odba_isolated_store
            }
            subs.odba_delete
            break
          when 'n'
            break
          when 'q'
            return
          when /c .+/u
            puts "creating:"
            pointer = Persistence::Pointer.new(:substance)
            puts "pointer: #{pointer}"
            args = { :lt => answer.split(/\s+/u, 2).last.strip }
            argstr = args.collect { |*pair| pair.join(' => ') }.join(', ')
            puts "args: #{argstr}"
            result = @system.update(pointer.creator, args)
            result.effective_form = result
            result.odba_store
            puts "result: #{result}"
          else
            result = @system.substance(answer)
          end
        end
        if(result)
          subs.effective_form = result
          subs.odba_store
        end
      }
      nil
    end

    def yus_allowed?(email, action, key=nil)
      YUS_SERVER.autosession(YUS_DOMAIN) { |session|
        session.entity_allowed?(email, action, key)
      }
    end
    def yus_create_user(email, pass=nil)
      YUS_SERVER.autosession(YUS_DOMAIN) { |session|
        session.create_entity(email, pass)
      }
      # if there is a password, we can log in
      login(email, pass) if(pass)
    end
    def yus_grant(name, key, item, expires=nil)
      YUS_SERVER.autosession(YUS_DOMAIN) { |session|
        session.grant(name, key, item, expires)
      }
    end
    def yus_get_preference(name, key)
      YUS_SERVER.autosession(YUS_DOMAIN) { |session|
        session.get_entity_preference(name, key)
      }
    rescue Yus::YusError
      # user not found
    end
    def yus_get_preferences(name, keys)
      YUS_SERVER.autosession(YUS_DOMAIN) { |session|
        session.get_entity_preferences(name, keys)
      }
    rescue Yus::YusError
      {} # return an empty hash
    end
    def yus_model(name)
      if(odba_id = yus_get_preference(name, 'association'))
        ODBA.cache.fetch(odba_id, nil)
      end
    rescue Yus::YusError, ODBA::OdbaError
      # association not found
    end
    def yus_reset_password(name, token, password)
      YUS_SERVER.autosession(YUS_DOMAIN) { |session|
        session.reset_entity_password(name, token, password)
      }
    end
    def yus_set_preference(name, key, value, domain=YUS_DOMAIN)
      YUS_SERVER.autosession(YUS_DOMAIN) { |session|
        session.set_entity_preference(name, key, value, domain)
      }
    end

    def migrate_feedbacks
      @system.each_package { |pac|
        _migrate_feedbacks(pac)
      }
      @system.feedbacks.odba_store
      @system.odba_store
      update_feedback_rss_feed
    end
    def _migrate_feedbacks(item)
      item = item.odba_instance
      fbs = item.instance_variable_get('@feedbacks').odba_instance
      case fbs
      when Array
        # already migrated, ignore
      when Hash
        new = fbs.values.select { |fb| 
          fb.is_a?(Feedback) 
        }.sort_by { |fb| fb.time }.reverse
        fbs.odba_delete
        new.odba_store
        item.instance_variable_set('@feedbacks', new)
        item.odba_store
        new.each { |fb|
          id = fb.odba_id
          fb.instance_variable_set('@oid', id)
          ptr = Persistence::Pointer.new([:feedback, id])
          fb.instance_variable_set('@pointer', ptr)
          @system.feedbacks.store(id, fb)
          fb.instance_variable_set('@item', item)
          fb.odba_store
        }
      when nil
        item.instance_variable_set('@feedbacks', [])
        item.odba_store
      end
    end
    def utf8ify(object, opts={})
      from = 'ISO-8859-1'
      to = 'UTF-8//TRANSLIT//IGNORE'
      if opts[:reverse]
        from, to = to, from
      end
      iconv = ::Iconv.new to, from
      _migrate_to_utf8([object], {}, iconv)
    end
    def migrate_to_utf8
      iconv = ::Iconv.new 'UTF-8//TRANSLIT//IGNORE', 'ISO-8859-1'
      ODBA.cache.retire_age = 5
      ODBA.cache.cleaner_step = 100000
      system = @system.odba_instance
      table = { system.odba_id => true, :serialized => {} }
      table.store :finalizer, proc { |object_id|
        table[:serialized].delete object_id }
      queue = [ system ]
      last_size = 0
      system.instance_variable_set '@config', nil
      while !queue.empty?
        if (queue.size - last_size).abs >= 10000
          puts last_size = queue.size
        end
        _migrate_to_utf8 queue, table, iconv, :all => true
      end
    end
    def _migrate_to_utf8 queue, table, iconv, opts={}
      obj = queue.shift
      if obj.is_a?(Numeric)
        begin
          obj = ODBA.cache.fetch obj
        rescue ODBA::OdbaError
          return
        end
      else
        obj = obj.odba_instance
      end
      _migrate_obj_to_utf8 obj, queue, table, iconv, opts
      obj.odba_store unless obj.odba_unsaved?
    end
    def _migrate_obj_to_utf8 obj, queue, table, iconv, opts={}
      obj.instance_variables.each do |name|
        child = obj.instance_variable_get name
        if child.respond_to?(:odba_unsaved?) && !child.odba_unsaved? \
          && obj.respond_to?(:odba_serializables) \
          && obj.odba_serializables.include?(name)
          child.instance_variable_set '@odba_persistent', nil
        end
        child = _migrate_child_to_utf8 child, queue, table, iconv, opts
        obj.instance_variable_set name, child
      end
      if obj.is_a?(Array)
        obj.collect! do |child|
          _migrate_child_to_utf8 child, queue, table, iconv, opts
        end
      end
      if obj.is_a?(Hash)
        obj.dup.each do |key, child|
          obj.store key, _migrate_child_to_utf8(child, queue, table, iconv, opts)
        end
        if obj.is_a?(ODDB::SimpleLanguage::Descriptions)
          obj.default = _migrate_child_to_utf8 obj.default, queue, table, iconv, opts
        end
      end
      obj
    end
    def _migrate_child_to_utf8 child, queue, table, iconv, opts={}
      @serialized ||= {}
      case child
      when ODBA::Persistable, ODBA::Stub
        if child = child.odba_instance
          if child.odba_unsaved?
            _migrate_to_utf8 [child], table, iconv, opts
          elsif opts[:all]
            odba_id = child.odba_id
            unless table[odba_id]
              table.store odba_id, true
              queue.push odba_id
            end
          end
        end
      when String
        child = iconv.iconv(child)
      when ODDB::Text::Section, ODDB::Text::Paragraph, ODDB::PatinfoDocument,
           ODDB::PatinfoDocument2001, ODDB::Text::Table, ODDB::Text::Cell,
           ODDB::Interaction::AbstractLink,
           ODDB::Dose
        child = _migrate_obj_to_utf8 child, queue, table, iconv, opts
      when ODDB::Address2
        ## Address2 may cause StackOverflow if not controlled
        unless table[:serialized][child.object_id]
          table[:serialized].store child.object_id, true
          ObjectSpace.define_finalizer child, table[:finalizer]
          child = _migrate_obj_to_utf8 child, queue, table, iconv, opts
        end
      when Float, Fixnum, TrueClass, FalseClass, NilClass,
        ODDB::Persistence::Pointer, Symbol, Time, Date, ODDB::Dose, Quanty,
        ODDB::Util::Money, ODDB::Fachinfo::ChangeLogItem, ODDB::AtcNode,
        DateTime, ODDB::NotificationLogger::LogEntry, ODDB::Text::Format,
        ODDB::YusStub, ODDB::Text::ImageLink
        # do nothing
      else
        @ignored ||= {}
        unless @ignored[child.class]
          @ignored.store child.class, true
          warn "ignoring #{child.class}"
        end
      end
      child
    rescue SystemStackError
      puts child.class
      raise
    end
    def log_size
      @size_logger = Thread.new {
        time = Time.now
        bytes = 0
        threads = 0
        sessions = 0
        format = "%s %s: sessions: %4i - threads: %4i  - memory: %4iMB %s"
        status = case @process
                 when :google_crawler ; 'status_google_crawler'
                 when :crawler        ; 'status_crawler'
                 else                 ; 'status'
                 end
        loop {
          begin
            next if defined?(Minitest)
            lasttime = time
            time = Time.now
            alarm = time - lasttime > 60 ? '*' : ' '
            lastthreads = threads
            threads = Thread.list.size
            # Shutdown if more than 200 threads are created, probably because of spiders
            if threads > 200
              exit
            end
            lastbytes = bytes
            bytes = File.read("/proc/#{$$}/stat").split(' ').at(22).to_i
            mbytes = bytes / (2**20)
            if mbytes > MEMORY_LIMIT
              puts "Footprint exceeds #{MEMORY_LIMIT}MB. Exiting. Exiting #{status}."
              Thread.main.raise SystemExit
            elsif /crawler/i.match(status) and mbytes > MEMORY_LIMIT_CRAWLER
              puts "Footprint exceeds #{MEMORY_LIMIT_CRAWLER}MB. Exiting #{status}."
              Thread.main.raise SystemExit
            end
            lastsessions = sessions
            sessions = @sessions.size
            gc = ''
            gc << 'S' if sessions < lastsessions
            gc << 'T' if threads < lastthreads
            gc << 'M' if bytes < lastbytes
            path = File.expand_path('../../doc/resources/downloads/' + status,
                                    File.dirname(__FILE__))
            lines = File.readlines(path)[0,100] rescue []
            lines.unshift sprintf(format, alarm, 
                                  time.strftime('%Y-%m-%d %H:%M:%S'),
                                  sessions, threads, mbytes, gc)
            File.open(path, 'w') { |fh|
              fh.puts lines
            }
          rescue StandardError => e
            puts e.class
            puts e.message
            $stdout.flush
          end
        sleep 5
        }
      }
    end
    # The followings are for migel data to access to migel drb server
    # @system (OddbPreverance) methods are replaced by the following methods
    def search_migel_alphabetical(query, lang)
      if lang == 'de' or lang == 'fr'
        search_method = 'search_by_name_' + lang.downcase.to_s
        MIGEL_SERVER.migelid.send(search_method, query)
      else
        []
      end
    end
    def search_migel_products(query, lang)
      migel_code = if query =~ /(\d){9}/
                     query.split(/(\d\d)/).select{|x| !x.empty?}.join('.')
                   elsif query =~ /(\d\d\.){4}\d/
                     query
                   end
      if migel_code
         MIGEL_SERVER.migelid.search_by_migel_code(migel_code)
         #MIGEL_SERVER.search_migel_product_by_migel_code(migel_code)
      else
        MIGEL_SERVER.search_migel_migelid(query, lang)
      end
    end
    def search_migel_group(migel_code)
      MIGEL_SERVER.group.find_by_migel_code(migel_code)
    end
    def search_migel_subgroup(migel_code)
      code = migel_code.split(/(\d\d)/).select{|x| !x.empty?}.join('.')
      MIGEL_SERVER.subgroup.find_by_migel_code(code)
    end
    def search_migel_limitation(migel_code)
      code = migel_code.split(/(\d\d)/).select{|x| !x.empty?}.join('.')
      MIGEL_SERVER.search_limitation(code)
    end
    def search_migel_items_by_migel_code(query, sortvalue = nil, reverse = nil)
      # migel_search event
      # search items by migel_code
      migel_code = if query =~ /(\d){9}/
                     query.split(/(\d\d)/).select{|x| !x.empty?}.join('.')
                   elsif query =~ /(\d\d\.){4}\d/
                     query
                   end
      MIGEL_SERVER.search_migel_product_by_migel_code(migel_code, sortvalue, reverse)
    end
    def search_migel_items(query, lang, sortvalue = nil, reverse = nil)
      # search event
      # search items by using search box
      if query =~ /^\d{13}$/
        MIGEL_SERVER.product.search_by_ean_code(query)
      elsif query =~ /^\d{6,}$/
        MIGEL_SERVER.product.search_by_pharmacode(query)
      else
        MIGEL_SERVER.search_migel_product(query, lang, sortvalue, reverse)
      end
    end
    def migel_product_index_keys(lang)
      MIGEL_SERVER.migelid_index_keys(lang)
    end
    def migel_count
      @migel_count ||= MIGEL_SERVER.migelids.length
    end

  end
end

begin 
  require ODDB.config.testenvironment1
rescue LoadError
end
puts "#{__FILE__}: calling OddbPrevalence.new"
OddbPrevalence.new
puts "#{__FILE__}: finishing"
