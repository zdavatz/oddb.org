#!/usr/bin/env ruby
# encoding: utf-8
# State::Drugs::ShortenPath-- oddb -- 14.05.2012 -- yasaka@ywesee.com

require 'state/drugs/init'

module ODDB
  module State
    module Drugs
class ShortenPath < State::Drugs::Init
  def init
    # redicert
    self.http_headers = {
      'Status'   => '303 See Other',
      'Location' => resolve_path
    }
    super
  end
  def resolve_path
    location = '/'
    @session.app.shorten_paths.each do |path|
      if path.shorten_path == @session.request_path
        location = path.origin_path
        break
      end
    end
    location
  end
end
    end
  end
end
