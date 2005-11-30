#!/usr/bin/env ruby
# View::TestDescriptionForm -- oddb -- 31.03.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'view/descriptionform'
require 'stub/cgi'

module ODDB
	module View
		class TestDescription < Test::Unit::TestCase
			class StubLookandfeel
				def languages
					%w{de fr}
				end
				def lookup(key)
					{
						:de		=>	'Deutsch',
					:fr		=>	'Franz&ouml;sisch',
					:update	=>	'Speichern',	
				}[key]
			end
			def attributes(key)
				{}
			end
			def method_missing(*args)
				''
			end
		end
			class StubSession
				def app	
					self
				end
				def error?
					false
				end
				def error(key)
					nil
				end
				def lookandfeel
					StubLookandfeel.new
				end
				def state
					self
				end
				def warning?
					false
				end
				def zone
					'twilight'
				end
			end
			class StubModel
				def description(language)
					{
						'de'	=>	'foo',
						'fr'	=>	'bar',
					}[language.to_s]
				end	
				def de
					description(:de)
				end
				def fr
					description(:fr)
				end
			end	
			class StubExtension	
				def initialize(*args)
				end
				def to_html(context)
					"extended!"
				end
			end
			class StubExtendedDescriptionForm < View::DescriptionForm
				COMPONENTS = {
					[2,0]	=>	:extension
				}
				SYMBOL_MAP = {
					:extension	=>	StubExtension
				}
			end

		def setup
			model = StubModel.new
			session = StubSession.new
			@form = StubExtendedDescriptionForm.new(model, session)
		end
		def test_to_html
			expected = <<-EOS
			<LABEL>Deutsch</LABEL>
			<INPUT name="de" type="text" value="foo">
			<LABEL>Franz&ouml;sisch</LABEL>
			<INPUT name="fr" type="text" value="bar">
			<INPUT name="update" type="submit" value="Speichern">
			EOS
			result = @form.to_html(CGI.new)
			expected.each { |line| 
				assert(result.index(line.strip!),"Expected: \n#{line}\nin:\n#{result}")
			}
		end
		def test_extended
			result = @form.to_html(CGI.new)
			assert(result.index("extended!"), "Expected: 'extended!' in: \n#{result}")
		end
		end
	end
end
