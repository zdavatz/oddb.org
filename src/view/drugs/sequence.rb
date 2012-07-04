#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::Sequence -- oddb -- 04.07.2012 -- yasaka@ywesee.com

require 'htmlgrid/composite'
require 'htmlgrid/value'

module ODDB
  module View
    module Drugs
class DivisionComposite < HtmlGrid::Composite
  COMPONENTS = {
    [0,0] => :division_divisable,
    [1,0] => :divisable,
    [0,1] => :division_dissolvable,
    [1,1] => :dissolvable,
    [0,2] => :division_crushable,
    [1,2] => :crushable,
    [0,3] => :division_openable,
    [1,3] => :openable,
    [0,4] => :division_notes,
    [1,4] => :notes,
    [0,5] => :division_source,
    [0,6] => :source,
  }
  COLSPAN_MAP = {
    [0,5] => 3,
    [0,6] => 4,
  }
  CSS_MAP = {
    [0,0] => 'list',
    [0,1] => 'list',
    [0,2] => 'list',
    [0,3] => 'list',
    [0,4] => 'list',
    [0,5] => 'list',
  }
  LABELS = true
  DEFAULT_CLASS = HtmlGrid::Value
  def divisable(model, session)
    HtmlGrid::Value.new(:divisable, model, session, self)
  end
  def dissolvable(model, session)
    HtmlGrid::Value.new(:dissolvable, model, session, self)
  end
  def crushable(model, session)
    HtmlGrid::Value.new(:crushable, model, session, self)
  end
  def openable(model, session)
    HtmlGrid::Value.new(:openable, model, session, self)
  end
  def notes(model, session)
    HtmlGrid::Value.new(:notes, model, session, self)
  end
  def source(model, session)
    HtmlGrid::Value.new(:source, model, session, self)
  end
end
    end
  end
end
