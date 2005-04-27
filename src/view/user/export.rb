#!/usr/bin/env ruby
# View::User::Export -- oddb -- 05.09.2003 -- hwyss@ywesee.com

module ODDB
	module View
		module User
module Export
	EXPORT_DIR = File.expand_path(
		'../../../doc/resources/downloads',
		File.dirname(__FILE__))
	EXPORT_FILE = ''
	def display?(path)
		File.exists?(path) && File.size(path) > 0
	end
	def export_link(key, filename)
		link = HtmlGrid::Link.new(key, @model, @session, self)
		args = {'filename'=>filename}
		link.href = @lookandfeel.event_url(:download, args)
		link.label = true
		link.set_attribute('class', 'list')
		link
	end
	def convert_filesize(path)
		kilo = (2**10).to_f
		size = File.size(path).to_f / kilo
		unit = "kB"
		if(size > kilo)
			size = size/kilo
			unit = "MB"
		end
		rounded = sprintf('%.2f', size)
		[
			"(",
			rounded,
			unit,
			")",
		].join("&nbsp;")
	end
	def checkbox_with_filesize(filename)
		if(display?(file_path(filename)))
			checkbox = HtmlGrid::InputCheckbox.new("download[#{filename}]", 
				@model, @session, self)
			#symbol = filename.tr(".", "_").downcase.intern
			#link = export_link(symbol, filename)
			size = filesize(filename)
			[checkbox, "#{filename} #{size}"]
		end
	end
	def once_or_year(filename)
		if(display?(file_path(filename)))
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
			[radio1, price1, radio2, price2]
		end
	end
	def file_path(filename)
		File.expand_path(filename, self::class::EXPORT_DIR)
	end
	def filesize(filename)
		if(display?(file_path(filename)))
			convert_filesize(file_path(filename))
		end
	end
end
		end
	end
end
