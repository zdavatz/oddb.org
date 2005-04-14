#!/usr/bin/env ruby
# Http -- ODDB -- 03.12.2003 -- hwyss@ywesee.com

require 'cgi'
require 'net/http'
require 'delegate'
require 'iconv'
require 'fileutils'

module ODDB
	module HttpFile
		def http_file(server, source, target, session=nil, hdrs = nil)
			session ||= Net::HTTP.new(server)
			resp = session.get(source, hdrs)
			if resp.is_a? Net::HTTPOK
				dir = File.dirname(target)
				FileUtils.mkdir_p(dir)
				File.open(target, 'w') { |file|
					file << resp.body
				}
				true
			end
		end
	end
	class HttpSession < DelegateClass(Net::HTTP)
		class ResponseWrapper < DelegateClass(Net::HTTPOK)
			def initialize(resp)
				@response = resp
				super
			end
			def body
				body = @response.body
				charset = self.charset
				unless(charset.nil? \
					|| %w{iso-8859-1 latin1}.include?(charset))
					cd = Iconv.new('Latin1', charset)
					begin
						latin = Iconv.iconv('Latin1', charset, body).first
					rescue
						body
					end
				else
					body
				end
			end
			def charset
				if((ct = @response['Content-Type']) \
					&& (match = /charset=([^;])+/.match(ct)))
					arr = match[0].split("=")
					arr[1].strip.downcase
				end
			end
		end
		HTTP_CLASS = Net::HTTP
		RETRIES = 0
		RETRY_WAIT = 10
		def initialize(http_server)
			@http_server = http_server
			@http = self.class::HTTP_CLASS.new(@http_server)
			@output = ''
			super(@http)
		end
		def post(path, hash)
			headers = post_headers
			resp = @http.post(path, post_body(hash), headers)
			if(resp.is_a? Net::HTTPOK)
				ResponseWrapper.new(resp)
			else
				raise("could not connect to #{@http_server}: #{resp}")
			end
		end
		def post_headers
			headers = get_headers
			headers.push(['Content-Type', 'application/x-www-form-urlencoded'])
		end
		def get_headers
			[	
				['Host', @http_server],
				['User-Agent', 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.7) Gecko/20040917 Firefox/0.9.3'],
				['Accept', 'text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,video/x-mng,image/png,image/jpeg,image/gif;q=0.2,*/*;q=0.1'],
				['Accept-Language', 'de-ch,en-us;q=0.7,en;q=0.3'],       ['Accept-Encoding', 'gzip,deflate'],
				['Accept-Charset', 'ISO-8859-1'],
				['Keep-Alive', '300'],
				['Connection', 'keep-alive'],
			]
		end
		def post_body(data)
			sorted = data.collect { |pair| 
				pair.collect { |item| CGI.escape(item) }.join('=') 
			}
			sorted.join("&")
		end
	end
end
