#!/usr/bin/env ruby
# TestValidator -- oddb -- 04.03.2003 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'util/validator'
require 'util/persistence'

class TestOddbValidator < Test::Unit::TestCase
	def setup
		@validator = ODDB::Validator.new
	end
	def test_atc_code
		assert_equal('N', @validator.validate(:code, 'N'))
		assert_equal('N01', @validator.validate(:code, 'N01'))
		assert_equal('N01A', @validator.validate(:code, 'N01A'))
		assert_equal('N01AB', @validator.validate(:code, 'N01AB'))
		assert_equal('N01AB02', @validator.validate(:code, 'N01AB02'))
		assert_equal(SBSM::InvalidDataError, @validator.validate(:code, 'N1AB02').class)
	end
	def test_description
		assert_equal('Eine Beschreibung', @validator.validate(:de, 'Eine Beschreibung'))
	end
	def test_dose
		assert_equal([10.0,'mg'], @validator.validate(:dose, '10 mg'))
		assert_equal([10.0,'mg'], @validator.validate(:dose, '10mg'))
		assert_equal([20.0, 'mg/ml'], @validator.validate(:dose, '20mg/ml'))
		assert_equal([20.0, 'mg/5ml'], @validator.validate(:dose, '20mg/5ml'))
		assert_equal([62.5, 'mg/g'], @validator.validate(:dose, '62.5mg/g'))
		assert_equal([62.5, 'mg/g'], @validator.validate(:dose, '62,5mg/g'))
	end
	def test_ikscd
		assert_equal('123', @validator.validate(:ikscd, '123'))
		assert_equal('003', @validator.validate(:ikscd, '3'))
		assert_equal(nil, @validator.validate(:ikscd, nil))
		assert_equal('', @validator.validate(:ikscd, ''))
		assert_equal(SBSM::InvalidDataError, @validator.validate(:ikscd, '123456').class)
		assert_equal(SBSM::InvalidDataError, @validator.validate(:ikscd, '1a34').class)
	end
	def test_iksnr
		assert_equal('12345', @validator.validate(:iksnr, '12345'))
		assert_equal(nil, @validator.validate(:iksnr, nil))
		assert_equal(SBSM::InvalidDataError, @validator.validate(:iksnr, '123').class)
		assert_equal(SBSM::InvalidDataError, @validator.validate(:iksnr, '123456').class)
		assert_equal(SBSM::InvalidDataError, @validator.validate(:iksnr, '1a345').class)
	end
	def test_pointer1
		pointer = ODDB::Persistence::Pointer.new(:foo, [:bar, '12345'])
		assert_equal(pointer, @validator.validate(:pointer, ':!foo!bar,12345.'))
	end
	def test_pointer2
		pointer = ODDB::Persistence::Pointer.new([:registration, '49390'])
		assert_equal(pointer, @validator.validate(:pointer, ':!registration,49390.'))
	end
	def test_pointer3
		pointer = ODDB::Persistence::Pointer.new([:registration, '49391'], [:sequence, '02'])
		assert_equal(pointer, @validator.validate(:pointer, ':!registration,49391!sequence,02.'))
	end
	def test_pointer4
		assert_nothing_raised {
			@validator.validate(:pointer, ':,arg,nocommand')	
		}
	end
	def test_search_query
		assert_equal('Ponstan', @validator.validate(:search_query, 'Ponstan'))
	end
	def test_search_query_shorter_than_3
		assert_equal(SBSM::InvalidDataError, @validator.validate(:search_query, 'Po').class)
	end
	def test_seqnr
		assert_equal('12', @validator.validate(:seqnr, '12'))
		assert_equal(nil, @validator.validate(:seqnr, nil))
		assert_equal('', @validator.validate(:seqnr, ''))
		assert_equal(SBSM::InvalidDataError, @validator.validate(:seqnr, '123').class)
		assert_equal(SBSM::InvalidDataError, @validator.validate(:seqnr, '1a3').class)
	end
	def test_set_pass
		expected = Digest::MD5.hexdigest('test')
		assert_equal(expected, @validator.validate(:set_pass_1, 'test'))
		assert_equal(expected, @validator.validate(:set_pass_2, 'test'))
	end
	def test_page
		assert_equal(0, @validator.validate(:page, "1"))
		assert_equal(1, @validator.validate(:page, "2"))
		#assert_equal(0, @validator.validate(:page, "0"))
		#assert_equal(-1, @validator.validate(:page, "-1"))
	end
	def test_filename
		assert_equal('oddb.yaml.gz', @validator.validate(:filename, "oddb.yaml.gz"))
		assert_equal(nil, @validator.validate(:filename, "/etc/passwd"))

	end
end
