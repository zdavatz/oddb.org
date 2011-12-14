#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestCoMarketingPlugin -- oddb.org -- 29.04.2011 -- mhatakeyama@ywesee.com
# ODDB::TestCoMarketingPlugin -- oddb.org -- 09.05.2006 -- hwyss@ywesee.com

$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'plugin/comarketing'

module ODDB
	class TestCoMarketingPlugin < Test::Unit::TestCase
    include FlexMock::TestCase
		def setup
			@app = flexmock('app')
			@plugin = ODDB::CoMarketingPlugin.new(@app)
		end
		def test_find
      flap_flag = false
			name = "Alpina Arnica-Gel mit Spilanthes, Gel"
			expected = [
				"Alpina Arnica Gel mit Spilanthes Gel",
				"Alpina Arnica Gel mit Spilanthes",
				"Alpina Arnica Gel mit",
				"Alpina Arnica Gel",
				"Alpina",
			]
      @app.should_receive(:registration).and_return nil
			@app.should_receive(:search_sequences, 10).and_return { |query, fuzzflag|
				assert_equal(flap_flag, fuzzflag)
        flap_flag = !flap_flag
        exp = expected.shift
				assert_equal(exp, query)
        if(flap_flag)
          expected.unshift(exp)
        end
				[]
			}
			result = @plugin.find(name)
			assert_nil(result)
      @app.flexmock_verify
		end
		def test_find__lacteol
      flap_flag = false
			name = "Lact?ol 5, capsules"
			expected = [
				"Lacteol 5 capsules",
				"Lacteol 5",
				"Lacteol",
			]
      @app.should_receive(:registration).and_return nil
			@app.should_receive(:search_sequences, 6).and_return { |query, fuzzflag|
				assert_equal(flap_flag, fuzzflag)
        flap_flag = !flap_flag
        exp = expected.shift
				assert_equal(exp, query)
        if(flap_flag)
          expected.unshift(exp)
        end
				[]
			}
			result = @plugin.find(name)
			assert_nil(result)
      @app.flexmock_verify
		end
		def test_find__lactoferment
      flap_flag = false
			name = "Lactoferment 5, Kapseln"
			expected = [
				"Lactoferment 5 Kapseln",
				"Lactoferment 5",
				"Lactoferment",
			]
      @app.should_receive(:registration).and_return nil
			@app.should_receive(:search_sequences, 6).and_return { |query, fuzzflag|
				assert_equal(flap_flag, fuzzflag)
        flap_flag = !flap_flag
        exp = expected.shift
				assert_equal(exp, query)
        if(flap_flag)
          expected.unshift(exp)
        end
				[]
			}
			result = @plugin.find(name)
			assert_nil(result)
		end
    def test_update_registration
      flexmock(@app, :update => 'update')
      @plugin.instance_eval('@updated = 0')
      original    = flexmock('original', :pointer => 'pointer')
      comarketing = flexmock('comarketing', 
                             :comarketing_with => nil,
                             :pointer => 'pointer'
                            )
      assert_equal('update', @plugin.update_registration(original, comarketing))
    end
    def test_update_pair
      @plugin.instance_eval('@found = 0')
      find_result = flexmock('find_result', :pointer => 'pointer')
      flexmock(find_result, :comarketing_with => find_result)
      flexmock(@app, :registration => find_result)
      assert_equal(nil, @plugin.update_pair('original_iksnr', 'comarketing_iksnr'))
    end
    def test_update_pair__not_found
      @plugin.instance_eval('@not_found = []')
      flexmock(@app, :registration => nil)
      expected = [["original_iksnr", "comarketing_iksnr"]]
      assert_equal(expected, @plugin.update_pair('original_iksnr', 'comarketing_iksnr'))
    end
    def test_report
      @plugin.instance_eval do
        @pairs     = []
        @not_found = []
        @deleted = 0
        @updated = 0
        @found = 0
      end
      expected = "Found                  0 Co-Marketing-Pairs\nof which               0 were found in the Database\nNew Connections:       0\nDeleted Connections:   0\n\nThe following          0 Original/Comarketing-Pairs were not found in the Database:\n"
      assert_equal(expected, @plugin.report)
    end
    def test_prune_comarketing
      registration2 = flexmock('registration2', :iksnr => 'iksnr')
      registration1 = flexmock('registration1', 
                               :comarketing_with => registration2,
                               :pointer => 'pointer'
                              )
      flexmock(@app, 
               :registrations => {'iksnr' => registration1},
               :update        => 'update'
              )
      @plugin.instance_eval('@deleted = 0')
      expect_pairs = [['original','comarketing']]
      expected = {"iksnr" => registration1}
      assert_equal(expected, @plugin.prune_comarketing(expect_pairs))
    end
    def test__sequence_registrations
      registration = flexmock('registration', :parallel_import => false)
      sequence     = flexmock('sequence', :registration => registration)
      expected = [registration]
      assert_equal(expected, @plugin._sequence_registrations([sequence]))
    end
    def test_sequence_registrations
      # if there is not a block
      registration1 = flexmock('registration1', :parallel_import => false)
      registration2 = flexmock('registration2', :parallel_import => false)
      sequence1     = flexmock('sequence1', 
                               :registration => registration1,
                               :active?      => true
                              )
      sequence2     = flexmock('sequence2', 
                               :registration => registration2,
                               :active?      => true
                              )
      expected = [registration1, registration2]
      assert_equal(expected, @plugin.sequence_registrations([sequence1, sequence2]))

      # if there is a block
      assert_equal(expected, @plugin.sequence_registrations([sequence1, sequence2]) {|seq| true})
    end
    def test__find__registration_size_1
      registration1 = flexmock('registration1', :parallel_import => false)
      sequence1     = flexmock('sequence1', 
                               :registration => registration1,
                               :active?      => true
                              )
      flexmock(@app, :search_sequences => [sequence1])
      assert_equal(registration1, @plugin._find('name'))
    end
    def test__find__registration_size__2
      registration1 = flexmock('registration1', :parallel_import => false)
      registration2 = flexmock('registration2', :parallel_import => false)
      galenic_form  = flexmock('galenic_form', :equivalent_to? => true)
      sequence1     = flexmock('sequence1', 
                               :registration => registration1,
                               :active?      => true,
                               :galenic_form => galenic_form
                              )
      sequence2     = flexmock('sequence2', 
                               :registration => registration2,
                               :active?      => true,
                               :galenic_form => 'galenic_form'
                              )
      flexmock(@app, 
               :search_sequences => [sequence1, sequence2],
               :galenic_form     => galenic_form
              )
      assert_equal(registration1, @plugin._find(', name'))
     end
	end
end
