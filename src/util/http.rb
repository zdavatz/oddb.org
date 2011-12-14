#!/usr/bin/env ruby
# encoding: utf-8
# Http -- ODDB -- 03.12.2003 -- hwyss@ywesee.com

require 'cgi'
require 'net/http'
require 'uri'
require 'delegate'
require 'iconv'
require 'fileutils'

module ODDB
	module HttpFile
		def http_file(server, source, target, session=nil, hdrs = nil)
			if(body = http_body(server, source, session, hdrs))
				dir = File.dirname(target)
				FileUtils.mkdir_p(dir)
				File.open(target, 'w') { |file|
					file << body
				}
				true
			end
		end
		def http_body(server, source, session=nil, hdrs=nil)
			session ||= HttpSession.new server
			resp = session.get(source, hdrs)
			if resp.is_a? Net::HTTPOK
				resp.body
			end
		end
	end
	class HttpSession < SimpleDelegator
		class ResponseWrapper < SimpleDelegator
			def initialize(resp)
				@response = resp
				super
			end
			def body
				body = @response.body
				charset = self.charset
				unless(charset.nil? || charset.downcase == 'utf-8')
					cd = Iconv.new('UTF-8', charset)
					begin
						cd.iconv body
					rescue
						body
					end
				else
					body
				end
			end
			def charset
				if((ct = @response['Content-Type']) \
					&& (match = /charset=([^;])+/u.match(ct)))
					arr = match[0].split("=")
					arr[1].strip.downcase
				end
			end
		end
		HTTP_CLASS = Net::HTTP
		RETRIES = 3
		RETRY_WAIT = 10
		def initialize(http_server, port=80)
			@http_server = http_server
			@http = self.class::HTTP_CLASS.new(@http_server, port)
			@output = ''
			super(@http)
		end
		def post(path, hash)
			retries = RETRIES
			headers = post_headers
			begin
				resp = @http.post(path, post_body(hash), headers)
				case resp
				when Net::HTTPOK
					ResponseWrapper.new(resp)
				when Net::HTTPFound
					uri = URI.parse(resp['location'])
					path = (uri.respond_to?(:request_uri)) ? uri.request_uri : uri.to_s
					warn(sprintf("redirecting to: %s", path))
					get(path)
				else
					raise("could not connect to #{@http_server}: #{resp}")
				end
			rescue Errno::ECONNRESET, EOFError
				if(retries > 0)
					retries -= 1
					sleep RETRIES - retries
					retry
				else
					raise
				end
			end
		end
		def post_headers
			headers = get_headers
			headers.push(['Content-Type', 'application/x-www-form-urlencoded'])
		end
		def get(*args)
			retries = RETRIES
			begin
				@http.get(*args)
			rescue Errno::ECONNRESET, Errno::ECONNREFUSED, EOFError
				if(retries > 0)
					retries -= 1
					sleep RETRIES - retries
					retry
				else
					raise
				end
			end
		end
		def get_headers
			[	
				['Host', @http_server],
				['User-Agent', "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_4_11; de-de) AppleWebKit/525.18 (KHTML, like Gecko) Version/3.1.2 Safari/525.22"],
				['Accept', 'text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,video/x-mng,image/png,image/jpeg,image/gif;q=0.2,*/*;q=0.1'],
				['Accept-Language', 'de-ch,en-us;q=0.7,en;q=0.3'],       
				['Accept-Charset', 'UTF-8'],
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
