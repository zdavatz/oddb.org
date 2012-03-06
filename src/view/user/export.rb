#!/usr/bin/env ruby
# encoding: utf-8
# View::User::Export -- oddb -- 06.03.2012 -- yasaka@ywesee.com
# View::User::Export -- oddb -- 05.09.2003 -- hwyss@ywesee.com

module ODDB
	module View
		module User
module Export
	EXPORT_DIR = File.expand_path(
		'../../../data/downloads',
		File.dirname(__FILE__))
	EXPORT_FILE = ''
	def datadesc(filename)
		if(display?(filename))
			link = HtmlGrid::Link.new(:data_description, 
				@model, @session, self)
			path = File.join('datadesc', "#{filename}.txt")
			link.href = @lookandfeel.resource_global(:downloads, path)
			link.css_class = 'small'
			link
		end
	end
	def display?(name)
		res = file_paths(name).any? { |path|
			File.exists?(path) && File.size(path) > 0
		}
    res
	end
	def example(filename)
		link = HtmlGrid::Link.new(:example_download, 
															@model, @session, self)
		link.href = @lookandfeel.resource_global(:examples, filename)
		link.css_class = 'small'
		link
	end
	def export_link(key, filename)
		link = HtmlGrid::Link.new(key, @model, @session, self)
		args = {'filename'=>filename}
		link.href = @lookandfeel._event_url(:download, args)
		link.label = true
		link.set_attribute('class', 'list')
		link
	end
	def convert_filesize(filename)
		kilo = (2**10)
		valid_paths = file_paths(filename).select { |path|
			File.exist?(path)
		}
		sizes = valid_paths.collect { |path|
			File.size(path)
		}
		size = sizes.max
		unit = 'Bytes'
		if(size > kilo)
			size = size / kilo
			unit = "KB"
		end
		if(size > kilo)
			size = size / kilo
			unit = "MB"
		end
		sprintf('(&nbsp;~&nbsp;%i&nbsp;%s)', size, unit)
	end
	def checkbox_with_filesize(filename)
		if(display?(filename))
			checkbox = HtmlGrid::InputCheckbox.new("download[#{filename}]", 
				@model, @session, self)
			size = filesize(filename)
			[checkbox, "&nbsp;", "#{filename} #{size}"]
		end
	end
	def once(filename)
		if(display?(filename))
			price = State::User::DownloadExport.price(filename)
			hidden = HtmlGrid::Input.new("months[#{filename}]", 
				@model, @session, self)
			hidden.set_attribute('type', 'hidden')
			hidden.value = '1'
			[@lookandfeel.format_price(price.to_i * 100, 'EUR'), hidden]
		end
	end
	def radio_price(filename, value='1')
		if(display?(filename))
			name = "months[#{filename}]"
			months = @session.user_input('months') || {}
			checked = months[filename] || '1'
			radio = HtmlGrid::InputRadio.new(name, @model, @session, self)
			radio.value = value
			if(checked == '1')
				radio.set_attribute('checked', true)
			end
			price = State::User::DownloadExport.price(filename)
			[radio, "&nbsp;", @lookandfeel.format_price(price.to_i * 100, 'EUR')]
		end
	end
	#legacy method (for htmlgrid.so)
	def once_or_year(filename)
		if(display?(filename))
			name = "months[#{filename}]"
			months = @session.user_input('months') || {}
			checked = months[filename] || '1'
			radio1 = HtmlGrid::InputRadio.new(name, @model, @session, self)
			price = State::User::DownloadExport.price(filename)
			price1 = @lookandfeel.format_price(price.to_i * 100, 'EUR')
			radio1.value = '1'
			if(checked == '1')
				radio1.set_attribute('checked', true)
			end
			radio2 = HtmlGrid::InputRadio.new(name, @model, @session, self)
			radio2.value = '12'
			if(checked == '12')
				radio2.set_attribute('checked', true)
			end
			price = State::User::DownloadExport.subscription_price(filename)
			price2 = @lookandfeel.format_price(price.to_i * 100, 'EUR')
			[radio1, nil, price1, nil, radio2, nil, price2]
		end
	end
	def file_path(filename)
		File.expand_path(filename, self::class::EXPORT_DIR)
	end
	def file_paths(filename)
    if uncompressed?(filename)
      return [File.expand_path(filename, self::class::EXPORT_DIR)]
    end
		['.zip', '.gz', '.tar.gz'].collect { |suffix|
			File.expand_path(filename + suffix, self::class::EXPORT_DIR)
		}
	end
	def filesize(filename)
		if(display?(filename))
			convert_filesize(filename)
		end
	end
  def uncompressed?(filename)
    DOWNLOAD_UNCOMPRESSED.include?(filename)
  end
end
		end
	end
end
