#!/usr/bin/env ruby
# -- oddb -- 26.11.2004 -- jlang@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", 
	File.dirname(__FILE__))
$: << File.expand_path("../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'meddata'
require 'flexmock' 

module ODDB
	module MedData
class SessionTest <Minitest::Test
	def setup
		@session = Session.new()
	end
	def test_post_hash__1
		data = {
			:name	=>	'Meier',
		}
		expected = [
			['__EVENTTARGET',	''],
			['__EVENTARGUMENT', ''],
			['btnSearch', 'Suche'],
			['txtSearchName', 'Meier'],
			['hiddenlang', 'de'],
		]
		result = @session.post_hash(data)
		assert_equal(expected, result)
	end
	def test_post_hash__utf8
			# The server expects utf8-encoded data
			data = {
				:name	=>	'Müller',
			}
			expected = [
				['__EVENTTARGET', ''],
				['__EVENTARGUMENT', ''],
				['btnSearch', 'Suche'],
				['txtSearchName', "M\303\274ller"],
				['hiddenlang', 'de'],
			]
			result = @session.post_hash(data)
			assert_equal(expected, result)
		end
	def test_post_hash__3
		data = {
			:name	=>	'Müller',
			:plz	=>	'8000',
		}
		expected = [
			['__EVENTTARGET',	''],
			['__EVENTARGUMENT', ''],
			['btnSearch',	'Suche'],
			['txtSearchName',	"M\303\274ller"],
			['txtSearchZIP', "8000"],
			['hiddenlang', 'de'],
		]
		result = @session.post_hash(data)
		assert_equal(expected, result)
	end
	def test_post_hash__4
		data = {
			:name			=>	'Müller',
			:plz			=>	'8000',
			:city			=>	'Cham',
			:state		=>	'Zug',
			:functions	=>	'Dienstleistungsfirma',
			:country	=>	'Schweiz',
		}
		expected = [
			['__EVENTTARGET',	''],
			['__EVENTARGUMENT', ''],
			['btnSearch', 'Suche'],
			['txtSearchName', "M\303\274ller"],
			['ddlSearchCountry', "Schweiz"],
			['txtSearchZIP', "8000",],
			['txtSearchCity', "Cham"],
			['ddlSearchStates', "Zug"],
			['ddlSearchFunctions', "Dienstleistungsfirma"],
			['hiddenlang', 'de'],
		]
		result = @session.post_hash(data)
		assert_equal(expected, result)
	end
end
	end
end
