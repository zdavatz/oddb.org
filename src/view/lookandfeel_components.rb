#!/usr/bin/env ruby
# encoding: utf-8
# View::LookandfeelComponents -- oddb.org -- 15.05.2007 -- hwyss@ywesee.com

module ODDB
  module View
module LookandfeelComponents
  def reorganize_components(lookandfeel_key, default='th')
    @components = @lookandfeel.send(lookandfeel_key)
    @css_map = {}
    @css_head_map = {}
    @components.each { |key, val|
      if(klass = self::class::CSS_KEYMAP[val])
        @css_map.store(key, klass)
        @css_head_map.store(key, self::class::CSS_HEAD_KEYMAP[val] || default)
      end
    }
  end
end
  end
end
