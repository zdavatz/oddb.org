#!/usr/bin/env ruby

require "diffy"
require "util/logfile"
require "htmlgrid/composite"
require "htmlgrid/div"
require "htmlgrid/form"
require "htmlgrid/image"
require "htmlgrid/link"
require "htmlgrid/list"
require "htmlgrid/span"
require "htmlgrid/value"
require "view/drugs/privatetemplate"

module ODDB
  module View
    module Drugs
      # By far the most frequent 500 on ch.oddb.org (21960 of ~25000 in August
      # 2026), on exactly the /diff/ pages Google crawls and then reports as
      # "Serverfehler (5xx)".
      #
      # The strings a ChangeLogItem stores in ODBA are clean UTF-8 - the binary
      # tag appears only while rendering: Diffy runs the external `diff` and
      # force-encodes its output to ASCII-8BIT whenever it is not valid UTF-8
      # (ydiffy diff.rb:60). The html formatter then re-diffs every chunk
      # character by character, and split_characters' String#split('') on a
      # binary string splits multi-byte UTF-8 sequences into single bytes. Those
      # go into a Tempfile, and because config.ru sets
      # Encoding.default_internal = UTF-8 that write transcodes and raises
      # Encoding::UndefinedConversionError ("\xC3" from ASCII-8BIT to UTF-8).
      #
      # Returns a copy whose diff text is tagged UTF-8, scrubbing only the bytes
      # that are really invalid so umlauts survive. The memoized @diff is preset,
      # so no second `diff` subprocess is spawned and the cached model object is
      # left untouched.
      def self.utf8_diff(diffy)
        raw = diffy.diff
        return diffy unless raw.is_a?(String)
        return diffy if raw.encoding == Encoding::UTF_8 && raw.valid_encoding?
        text = raw.dup.force_encoding(Encoding::UTF_8)
        text = text.scrub("?") unless text.valid_encoding?
        copy = Diffy::Diff.new(diffy.string1.to_s, diffy.string2.to_s, diffy.options)
        copy.instance_variable_set(:@diff, text)
        copy
      rescue => error
        LogFile.debug("View::Drugs.utf8_diff: #{error.class} #{error.message}")
        diffy
      end

      # Stand bis August 2026 in patinfo.rb; fachinfo.rb braucht sie
      # genauso und lud sie nicht. Beide Dateien laden change_logs.rb.
      # #change_log is declared as an Array, but the reference can resolve to an
      # unrelated ODBA object (137 of the 500s in August 2026 were
      # "undefined method 'size' for an instance of ODDB::PatinfoDocument").
      # Treat anything that cannot answer #size as "no change log".
      def self.change_log_size(document)
        change_log = document.change_log
        change_log.respond_to?(:size) ? change_log.size : 0
      rescue => error
        LogFile.debug("View::Drugs.change_log_size: #{error.class} #{error.message}")
        0
      end

      def self.get_show_change_link_href(model, pack_or_reg, lnf, supress_date = false)
        may_be_date = supress_date ? [] : [model.time.strftime("%d.%m.%Y")]
        if pack_or_reg.is_a?(ODDB::Registration)
          # http://ch.oddb.org/fr/gcc/show/fachinfo/65511/diff
          lnf._event_url(:show, [:fachinfo,
            pack_or_reg.iksnr,
            :diff] + may_be_date)
        elsif pack_or_reg.is_a?(ODDB::Package)
          # http://ch.oddb.org/de/gcc/show/patinfo/56195/01/002/diff
          lnf._event_url(:show, [:patinfo,
            pack_or_reg.iksnr,
            pack_or_reg.seqnr,
            pack_or_reg.ikscd,
            :diff] + may_be_date)
        end
      end

      def self.get_change_log_href_and_value(pack_or_reg, lnf)
        if pack_or_reg.is_a?(ODDB::Registration)
          # http://ch.oddb.org/fr/gcc/show/fachinfo/65511/diff
          href = lnf._event_url(:fachinfo, [:reg, pack_or_reg.iksnr])
          value = lnf.lookup(:fachinfo_name0) + pack_or_reg.name_base
        elsif pack_or_reg.is_a?(ODDB::Package)
          # http://ch.oddb.org/de/gcc/show/patinfo/56195/01/002/diff
          href = lnf._event_url(:patinfo, [:reg, pack_or_reg.iksnr,
            :seq, pack_or_reg.seqnr,
            :pack, pack_or_reg.ikscd])
          value = lnf.lookup(:patinfo_name0) + pack_or_reg.name_base
        end
        [href, value]
      end

      class DocumentChangelogItemComposite < HtmlGrid::Composite
        LEGACY_INTERFACE = false
        COMPONENTS = {
          [0, 0, 0] => :nr_chunks,
          [0, 0, 1] => "&nbsp",
          [0, 0, 2] => "th_change_log",
          [0, 0, 3] => "&nbsp",
          [0, 0, 4] => :name,
          [0, 1] => :diff
        }
        CSS_MAP = {
          [0, 0] => "th"
        }
        CSS_CLASS = "composite"
        DEFAULT_CLASS = HtmlGrid::Value
        def init
          change_log_key = components.find { |x, y| y.eql?("th_change_log") }.first
          if @session.choosen_info_diff.first.is_a?(ODDB::Registration)
            components[change_log_key] = "th_change_log_FI"
          elsif @session.choosen_info_diff.first.is_a?(ODDB::Package)
            components[change_log_key] = "th_change_log_PI"
          end
          super
        end

        def diff(model)
          Drugs.utf8_diff(model.diff).to_s(:html)
        end

        def nr_chunks(model)
          return unless model and @session.choosen_info_diff.size > 0
          j = 0
          model.diff.each_chunk { |x| j += 1 }
          j
        end

        def name(model)
          return unless model and @session.choosen_info_diff.size > 0
          @session.choosen_info_diff.first.name_base
        end

        def time(model)
          model.time.strftime("%d.%m.%Y")
        end
      end

      class DocumentChangelogItem < PrivateTemplate
        CONTENT = View::Drugs::DocumentChangelogItemComposite
        SNAPBACK_EVENT = :change_log
        def backtracking(model, session = @session)
          class_name = "breadcrumbs"
          fields = []
          link_home = HtmlGrid::Link.new(:home, model, @session, self)
          link_home.css_class = class_name
          link_home.href = @lookandfeel._event_url(:home, [])
          link_home.value = @lookandfeel.lookup(:home)
          fields << link_home
          fields << "&nbsp;-&nbsp;"

          link_ref = HtmlGrid::Link.new(:home, model, @session, self)
          link_ref.css_class = class_name
          link_ref.href, link_ref.value = Drugs.get_change_log_href_and_value(@session.choosen_info_diff.first, @lookandfeel)
          fields << link_ref

          fields << "&nbsp;-&nbsp;"
          link_changes = HtmlGrid::Link.new(:home, model, @session, self)
          link_changes.css_class = class_name
          link_changes.href = Drugs.get_show_change_link_href(model, @session.choosen_info_diff.first, @lookandfeel, :supress_date)
          link_changes.value = @lookandfeel.lookup(:change_log_backtracking)
          fields << link_changes

          fields << "&nbsp;-&nbsp;"
          span = HtmlGrid::Span.new(model, session, self)
          span.value = model.time.strftime("%d.%m.%Y")
          span.set_attribute("class", class_name)
          fields << span
          fields
        end
      end

      class ChangelogList < HtmlGrid::List
        LEGACY_INTERFACE = false
        CSS_CLASS = "composite"
        COMPONENTS = {
          [0, 0] => :trademark,
          [1, 0] => :nr_chunks,
          [2, 0] => :change_log_date
        }
        SORT_DEFAULT = false
        SORT_HEADER = false
        def nr_chunks(model)
          return unless model and @session.choosen_info_diff.size > 0
          nr = 0
          model.diff.each_chunk { |x| nr += 1 }
          link = HtmlGrid::Link.new(:change_log, model, @session, self)
          link.href = Drugs.get_show_change_link_href(model, @session.choosen_info_diff.first, @lookandfeel)
          link.value = nr
          link
        end

        def change_log_date(model)
          return unless model and @session.choosen_info_diff.size > 0
          link = HtmlGrid::Link.new(:change_log, model, @session, self)
          link.href = Drugs.get_show_change_link_href(model, @session.choosen_info_diff.first, @lookandfeel)
          link.value = model.time.strftime("%d.%m.%Y")
          link
        end

        def trademark(model)
          return unless model and @session.choosen_info_diff.size > 0
          link = HtmlGrid::Link.new(:change_log, model, @session, self)
          link.href = Drugs.get_show_change_link_href(model, @session.choosen_info_diff.first, @lookandfeel)
          link.value = @session.choosen_info_diff.first.name_base
          link
        end
      end

      class ChangelogsComposite < HtmlGrid::Composite
        LEGACY_INTERFACE = false
        CSS_CLASS = "composite"
        COMPONENTS = {
          [0, 0] => ChangelogList
        }
        def initialize(model, session, container)
          # latest changes must come first!
          model.sort! { |x, y| y.time.to_s <=> x.time.to_s }
          super
        end
      end

      class DocumentChangelogs < View::PrivateTemplate
        SEARCH_HEAD = View::SelectSearchForm
        CONTENT = View::Drugs::ChangelogsComposite
        def backtracking(model, session = @session)
          class_name = "breadcrumbs"
          fields = []
          link_home = HtmlGrid::Link.new(:home, model, @session, self)
          link_home.css_class = class_name
          link_home.href = @lookandfeel._event_url(:home, [])
          link_home.value = @lookandfeel.lookup(:home)
          fields << link_home
          return fields unless @session.choosen_info_diff.first

          fields << "&nbsp;-&nbsp;"
          link = HtmlGrid::Link.new(:home, model, @session, self)
          link.css_class = class_name
          link.href, link.value = Drugs.get_change_log_href_and_value(@session.choosen_info_diff.first, @lookandfeel)
          fields << link

          fields << "&nbsp;-&nbsp;"
          span = HtmlGrid::Span.new(model, session, self)
          span.value = @lookandfeel.lookup(:change_log_backtracking)
          span.set_attribute("class", class_name)
          fields << span
          fields
        end
      end

      class EmptyResultForm < HtmlGrid::Form
        CSS_CLASS = "composite"
        COMPONENTS = {
          [0, 1] => :title_none_found,
          [0, 2] => "e_empty_result"
        }
        CSS_MAP = {
          [0, 0] => "search",
          [0, 1] => "th"
        }
        def title_none_found(model, session)
          @lookandfeel.lookup(:title_none_found)
        end
      end
    end
  end
end
