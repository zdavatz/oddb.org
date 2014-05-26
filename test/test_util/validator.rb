#!/usr/bin/env ruby
# encoding: utf-8
# TestValidator -- oddb.org -- 08.11.2011 -- mhatakeyama@ywesee.com
# TestValidator -- oddb.org -- 04.03.2003 -- hwyss@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'util/validator'
require 'util/persistence'
require 'sbsm/validator'

class TestOddbValidator <Minitest::Test
  include FlexMock::TestCase
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
		assert_equal('00300', @validator.validate(:iksnr, '00300'))
		assert_equal('12345', @validator.validate(:iksnr, '12345'))
		assert_equal('1234567890', @validator.validate(:iksnr, '1234567890'))
		assert_equal(nil, @validator.validate(:iksnr, nil))
		assert_equal(SBSM::InvalidDataError, @validator.validate(:iksnr, '123').class)
		assert_equal(SBSM::InvalidDataError, @validator.validate(:iksnr, '12345678901').class)
		assert_equal(SBSM::InvalidDataError, @validator.validate(:iksnr, '1a345').class)
	end
	def test_pointer1
    error = @validator.validate(:pointer, ':!foo!bar,12345.')
		assert_instance_of(SBSM::InvalidDataError, error)
	end
	def test_pointer2
		pointer = ODDB::Persistence::Pointer.new([:registration, '49390'])
		assert_kind_of(SBSM::InvalidDataError, @validator.validate(:pointer, ':!registration,49390.'))
	end
	def test_pointer3
		pointer = ODDB::Persistence::Pointer.new([:registration, '49391'], [:sequence, '02'])
		assert_kind_of(SBSM::InvalidDataError, @validator.validate(:pointer, ':!registration,49391!sequence,02.'))
	end
	def test_pointer4
    @validator.validate(:pointer, ':,arg,nocommand')	
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
  def test_ean13
    assert_equal('7680382940243', @validator.ean13('7680382940243'))
  end
  def test_ean13__empty
    assert_equal('', @validator.ean13(''))
  end
  def test_ean13__error
    assert_raises(SBSM::InvalidDataError) do
      @validator.ean13('12345')
    end
  end
  def test_emails
    assert_equal(['abc@ywesee.com'], @validator.emails('abc@ywesee.com'))
  end
  def test_emails__invalid_email
    assert_raises(SBSM::InvalidDataError) do 
      @validator.emails('abc_at_ywesee.com')
    end
  end
  def test_emails__nil
    assert_equal(nil, @validator.emails(''))
  end
  def test_emails__domainless
    # Actuall, I do not know how to make the result 'domainless'
    # without flexmock
    result = flexmock('result') do |r|
      r.should_receive(:empty?).and_return(false)
      r.should_receive(:all?).and_return(false)
    end
    flexmock(Mail::Address) do |r|
      r.should_receive(:parse).and_return(result)
    end
    assert_raises(SBSM::InvalidDataError) do 
      @validator.emails('abc')
    end
  end
  def test_email_suggestion
    assert_equal('abc@ywesee.com', @validator.email_suggestion('abc@ywesee.com'))
  end
  def test_pointer
    pointer = ':!registration,49390.'
    assert_raises(SBSM::InvalidDataError) do 
      @validator.pointer(pointer)
    end
  end
  def test_pointer__invalid_pointer
    assert_raises(SBSM::InvalidDataError) do
      @validator.pointer('value')
    end
  end
  def test_galenic_group
    pointer = ':!registration,49390.'
    assert_raises(SBSM::InvalidDataError) do 
       @validator.galenic_group(pointer)
    end
  end
  def test_ikscat
    assert_equal('A', @validator.ikscat('Ahogehoge'))
  end
  def test_ikscat__error
    assert_raises(SBSM::InvalidDataError) do
      @validator.ikscat('value')
    end
  end
  def test_ikscat__empty
    assert_equal('', @validator.ikscat(''))
  end
  def test_notify_recipient
    assert_equal(['abc@ywesee.com'], @validator.notify_recipient('abc@ywesee.com'))
  end
  def test_set_pass_1
    assert_equal('5f4dcc3b5aa765d61d8327deb882cf99', @validator.set_pass_1('password'))
  end
  def test_set_pass_1__error
    assert_raises(SBSM::InvalidDataError) do
      @validator.set_pass_1('pas')
    end
  end
  def test_yus_association
    assert_equal('org.oddb.model.hogehoge', @validator.yus_association('org.oddb.model.hogehoge'))
  end
  def test_yus_association__error
    assert_raises(SBSM::InvalidDataError) do 
      @validator.yus_association('value')
    end
  end
  def test_zone
    assert_equal(:admin, @validator.zone('admin'))
  end
  def test_zone__empty
    assert_raises(SBSM::InvalidDataError) do
      @validator.zone('')
    end
  end
  def test_zone__error
    assert_raises(SBSM::InvalidDataError) do
      @validator.zone('value')
    end
  end
  def test_code__empty
    assert_equal(nil, @validator.code(''))
  end
  def test_dose__error
    assert_raises(SBSM::InvalidDataError) do
      @validator.dose('hogehoge')
    end
  end
end
