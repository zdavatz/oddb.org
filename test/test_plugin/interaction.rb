#!/usr/bin/env ruby
# TestInteractionPlugin -- oddb -- 15.03.2011 -- mhatakeyama@ywesee.com
# TestInteractionPlugin -- oddb -- 23.02.2004 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'plugin/interaction'
require 'util/html_parser'
require 'flexmock'

module ODDB
  module Interaction
    class InteractionPlugin < Plugin
      class Substance; end
    end
  end
end

module ODDB
	module Interaction
		class InteractionPlugin
			attr_accessor :hayes, :flockhart
			attr_accessor :hayes_conn_not_found, :flock_conn_not_found
			attr_accessor :updated_substances, :update_reports
			REFETCH_PAGES = false
		end
	end
end

class TestInteractionPlugin < Test::Unit::TestCase
  include FlexMock::TestCase
  def TestInteractionPlugin.cyt_hsh(cyt_range, option=nil)
    cyts = {}
    cyt_range.each { |dig|
      cyts.store("cyt_#{dig}", ODDB::Interaction::Cytochrome.new("cyt_#{dig}"))
    }
    cyts.each { |key, value|
      TestInteractionPlugin.add_types(value)
    }
    if(option=="links")
      cyts.values.each { |cyt|
        ODDB::Interaction::InteractionPlugin::INTERACTION_TYPES.each { |type|
          cyt.send(type).each { |conn|
            conn.add_link("conn_link")
          }
        }
      }
    end
    if(option=="categories")
      cyts.values.each { |cyt|
        ODDB::Interaction::InteractionPlugin::INTERACTION_TYPES.each { |type|
          cyt.send(type).each { |conn|
            conn.category="conn_cat"
          }
        }
      }
    end
    cyts
  end
  def TestInteractionPlugin.add_types(cyt)
    (1..2).each { |dig|
      cyt.substrates.push(ODDB::Interaction::SubstrateConnection.new("sub_#{dig}"))
    }
    (1..3).each { |dig|
      cyt.inhibitors.push(ODDB::Interaction::InhibitorConnection.new("inh_#{dig}"))
    }
    (1..4).each { |dig|
      cyt.inducers.push(ODDB::Interaction::InducerConnection.new("ind_#{dig}"))
    }
    cyt
  end
  def setup
    @app = flexmock('app')
    @plugin = ODDB::Interaction::InteractionPlugin.new(@app)
    @mock_plugin = flexmock('mock_plugin') 
  end
  def teardown
  end
  def test_flock_conn_name
    flock_conn = flexmock('flock_conn', :name => 'acetaminophen=')
    result = @plugin.flock_conn_name(flock_conn)
    assert_equal("acetaminophen", result)
  end
  def test_flock_conn_name2
    flock_conn = flexmock('flock_conn', :name => 'acetaminophen (in part)')
    result = @plugin.flock_conn_name(flock_conn)
    assert_equal("acetaminophen", result)
  end
  def test_parse_hayes
    interaction = flexmock('interaction')
    cytochrome = flexmock('cytochrome')
    connection = flexmock('connection')
    flexmock(@mock_plugin,
             :parse_substrate_table   => {'foo' => cytochrome},
             :parse_interaction_table => {'foo' => interaction}
            )
    flexmock(interaction, 
             :inhibitors => [connection],
             :inducers   => [connection]
            )
    flexmock(cytochrome, :add_connection => nil)
    expected = {'foo' => cytochrome}
    assert_equal(expected, @plugin.parse_hayes(@mock_plugin))
  end
  def test_report
    @plugin.flock_conn_not_found = 3 
    @plugin.hayes_conn_not_found = 2 
    @plugin.hayes = { 
      'foo' =>	'foobar',
      'bar'	=>	'foobar',
    }
    @plugin.flockhart = { 
      'foobar'	=>	'foobar',
      'barfoo'	=>	'foobar',
    }
    result = @plugin.report.split("\n").sort
    expected = [
      "found hayes cytochromes: 2",
      "bar, foo",
      "found flock cytochromes: 2",
      "barfoo, foobar",
      "There are no matching hayes connections for 2 flockhart connections",
      "There are no matching flockhart connections for 3 hayes connections",
    ]
    assert_equal(expected.sort, result)
  end
  def test_report2
    @plugin.flock_conn_not_found = 3 
    @plugin.hayes_conn_not_found = 2 
    @plugin.update_reports = {
      :cyp450_created			=>	[ 'cyp450', 'cyp450_2' ],
      :substance_created	=>	[ 'substance' ],
      :inhibitors_created	=>	[ 'inhibitor updated' ],
      :inhibitors_deleted	=>	[ 'inhibitor deleted' ],
      :inducers_created		=>	[ 'inducer updated' ],
      :inducers_deleted		=>	[ 'inducer deleted' ],
      :substrates_created	=>	[ 'substrate updated' ],
      :substrates_deleted	=>	[ 'substrate deleted' ],
    }
    @plugin.hayes = { 
      'foo' =>	'foobar',
      'bar'	=>	'foobar',
    }
    @plugin.flockhart = { 
      'foobar'	=>	'foobar',
      'barfoo'	=>	'foobar',
    }
    result = @plugin.report.split("\n").sort
    expected = [
      "found hayes cytochromes: 2",
      "bar, foo",
      "found flock cytochromes: 2",
      "barfoo, foobar",
      "There are no matching hayes connections for 2 flockhart connections",
      "There are no matching flockhart connections for 3 hayes connections",
      ODDB::Interaction::InteractionPlugin::UPDATE_MESSAGES[:cyp450_created],
      "cyp450", "cyp450_2", 
      ODDB::Interaction::InteractionPlugin::UPDATE_MESSAGES[:substance_created],
      "substance",
      ODDB::Interaction::InteractionPlugin::UPDATE_MESSAGES[:inhibitors_created],
      "inhibitor updated",
      ODDB::Interaction::InteractionPlugin::UPDATE_MESSAGES[:inhibitors_deleted],
      "inhibitor deleted",
      ODDB::Interaction::InteractionPlugin::UPDATE_MESSAGES[:inducers_created],
      "inducer updated",
      ODDB::Interaction::InteractionPlugin::UPDATE_MESSAGES[:inducers_deleted],
      "inducer deleted",
      ODDB::Interaction::InteractionPlugin::UPDATE_MESSAGES[:substrates_created],
      "substrate updated",
      ODDB::Interaction::InteractionPlugin::UPDATE_MESSAGES[:substrates_deleted],
      "substrate deleted",
    ]
    assert_equal(expected.sort, result)
  end
  def test_similar_name
    subs = flexmock('Substance', :same_as? => 'result')
    flexmock(@app, :substance => subs)
    assert_equal('result', @plugin.similar_name?('astring', 'bstring'))
  end
  def test_update_oddb_cyp450
    cyp450 = flexmock('cyp450')
    flexmock(@app, :cyp450 => 'cyp450')
    assert_equal('cyp450', @plugin.update_oddb_cyp450('foo_id', 'cytochrome'))
  end
  def test_update_oddb_cyp4502
    cytochrome = flexmock('cytochrome')
    cyp450 = flexmock('cyp450', :cyp_id => 'cyp450_id')
    flexmock(@app) do |a|
      a.should_receive(:cyp450).once.with('foo_id')
      a.should_receive(:create).once.with(ODDB::Persistence::Pointer).
        and_return(cyp450)
    end
    assert_equal(cyp450, @plugin.update_oddb_cyp450('foo_id', cytochrome))
  end
  def test_update_oddb_create_substance
    connection = flexmock('connection',
                          :lang => 'en',
                          :name => 'not_yet_updated'
                         )
    substance  = flexmock('substance',
                          :name => 'not_yet_updated'
                         )
    flexmock(@app, :update => substance)
    expected = { substance =>	{} }
    assert_equal(['not_yet_updated'], @plugin.update_oddb_create_substance(connection))
    assert_equal(expected, @plugin.instance_variable_get('@updated_substances'))
  end
  def test_update_oddb_substrates
    cytochrome = flexmock('cytochrome')
    substrate = flexmock('substrate')
    substance = flexmock('substance')
    connection = flexmock('connection')
    pointer = flexmock('pointer', :creator => 'creator')
    flexmock(pointer, :+ => pointer)
    @plugin.updated_substances = { 
      'found'	=>	{ 
        :connections	=>	{ 
          'cyt_id'	=> connection
        }
      }
    }
    flexmock(cytochrome, :substrates => [substrate])
    flexmock(substrate,
             :links     => 'links',
             :category  => 'category',
             :name      => 'substratename'
            )
    flexmock(substance,
             :pointer   => pointer,
             :primary_connection_key => 'substratename'
            )
    flexmock(substance) do |s|
      s.should_receive(:cyp450substrate).once.
        with('cyt_id').and_return(false)
    end
    flexmock(@app,
             :update  => nil,                     
             :substance_by_connection_key => substance
            )
    expected = [substrate]
    assert_equal(expected, @plugin.update_oddb_substrates('cyt_id', cytochrome))
  end
  def test_update_oddb_substances
    substance  = flexmock('substance', :substrate_connections => 'connections')
    flexmock(@app, :substance_by_connection_key => substance)
    substrate  = flexmock('substrate', :name => 'name')
    cytochrome = flexmock('cytochrome', 
                         :substrates => [substrate],
                         :inhibitors => [substrate],
                         :inducers   => [substrate]
                         )
    expected = [substrate, substrate, substrate]
    assert_equal(expected, @plugin.update_oddb_substances(cytochrome))
  end
  def test_update_oddb_substances__else
    substance  = flexmock('substance', :substrate_connections => 'connections')
    update     = flexmock('update', :name => 'name')
    flexmock(@app, 
             :update => update,
             :substance_by_connection_key => nil
            )
    substrate  = flexmock('substrate', 
                          :name => 'name',
                          :lang => 'lang'
                         )
    cytochrome = flexmock('cytochrome', 
                         :substrates => [substrate],
                         :inhibitors => [substrate],
                         :inducers   => [substrate]
                         )
    expected = [substrate, substrate, substrate]
    assert_equal(expected, @plugin.update_oddb_substances(cytochrome))
  end
  def test_update_oddb_cyp450_connections
    connection  = flexmock('connection', 
                           :name       => 'name',
                           :links      => 'links',
                           :category   => nil,
                           :auc_factor => nil
                          )
    cyt         = flexmock('cyt', :connection => [connection])
    pointer     = flexmock('pointer', :creator => nil)
    flexmock(pointer, :+ => pointer)
    cyp450      = flexmock('cyp450', 
                           #:connection => {'key' => 'value', 'primary_connection_key' => 'value'},
                           :connection => {'key' => 'value'},
                           :pointer    => pointer,
                           :cyp_id     => 'cyp_id'
                          )
    substance   = flexmock('substance', :primary_connection_key => 'primary_connection_key')
    flexmock(@app, 
             :update                      => nil,
             :delete                      => nil,
             :substance_by_connection_key => substance
            )
    @plugin.instance_eval('@update_reports[:connection_created] = []')
    @plugin.instance_eval('@update_reports[:connection_deleted] = []')
    assert_equal(['key'], @plugin.update_oddb_cyp450_connections('cyt_id', cyt, cyp450, :connection))
  end
  def test_update_oddb_cyp450_connections__include
    connection  = flexmock('connection', 
                           :name       => 'name',
                           :links      => 'links',
                           :category   => nil,
                           :auc_factor => nil
                          )
    cyt         = flexmock('cyt', :connection => [connection])
    pointer     = flexmock('pointer', :creator => nil)
    flexmock(pointer, :+ => pointer)
    cyp450      = flexmock('cyp450', 
                           :connection => {'key' => 'value', 'primary_connection_key' => 'value'},
                           #:connection => {'key' => 'value'},
                           :pointer    => pointer,
                           :cyp_id     => 'cyp_id'
                          )
    substance   = flexmock('substance', :primary_connection_key => 'primary_connection_key')
    flexmock(@app, 
             :update                      => nil,
             :delete                      => nil,
             :substance_by_connection_key => substance
            )
    @plugin.instance_eval('@update_reports[:connection_created] = []')
    @plugin.instance_eval('@update_reports[:connection_deleted] = []')
    assert_equal(['key'], @plugin.update_oddb_cyp450_connections('cyt_id', cyt, cyp450, :connection))
  end
  def test_update_oddb
    pointer    = flexmock('pointer', :creator => nil)
    connection = flexmock('connection')
    substrate  = flexmock('substrate', 
                          :name       => 'name',
                          :creator    => 'creator',
                          :links      => 'links',
                          :category   => nil,
                          :auc_factor => nil
                         )
    substance = flexmock('substance', 
                         :pointer                => pointer,
                         :cyp450substrate        => substrate,
                         :substrate_connections  => [connection], 
                         :primary_connection_key => 'primary_connection_key'
                        )
    flexmock(pointer, :+ => pointer)
    cyp450 = flexmock('cyp450', 
                      :cyp_id     => 'cyp_id',
                      :pointer    => pointer,
                      :inhibitors => {'key' => substrate},
                      :inducers   => {'key' => substrate}
                     )
    flexmock(@app, 
             :cyp450 => cyp450,
             :update => nil,
             :delete => nil,
             :substance_by_connection_key => substance)

    cytochrome = flexmock('cytocrhome', 
                          :substrates => [substrate],
                          :inhibitors => [substrate],
                          :inducers   => [substrate]
                         )
    cytochrome_hash = {'cyt_id' => cytochrome}
    expected = {substance => [connection]}
    assert_equal(expected, @plugin.update_oddb(cytochrome_hash))
  end
  def test_update
    # for parse_hayes
    # for parse_flockhart
    interaction = flexmock('interaction')
    cytochrome = flexmock('cytochrome')
    connection = flexmock('connection')
    flexmock(@mock_plugin,
             :parse_substrate_table   => {'foo' => cytochrome},
             :parse_interaction_table => {'foo' => interaction}
            )
    flexmock(interaction, 
             :inhibitors => [connection],
             :inducers   => [connection]
            )
    flexmock(ODDB::Interaction::HayesPlugin, :new => @mock_plugin)

    substrate1 = flexmock('substrate1', 
                         :name        => 'name1',
                         :auc_factor  => nil,
                         :auc_factor= => nil,
                         :category    => nil,
                         :category=   => nil,
                         :links       => 'links'
                        )
    substrate2 = flexmock('substrate2', 
                         :name        => 'name2',
                         :auc_factor  => nil,
                         :auc_factor= => nil,
                         :category    => nil,
                         :category=   => nil,
                         :links       => 'links'
                        )
    flexmock(cytochrome, 
             :substrates => [substrate1],
             :inhibitors     => [substrate1],
             :inducers       => [substrate2],
             :add_connection => nil
            )
    plugin = flexmock('plugin',
                     :parse_table         => {'cyt_id' => cytochrome},
                     :parse_detail_pages  => {'cyt_id' => cytochrome}
                     )
    flexmock(ODDB::Interaction::FlockhartPlugin, :new => plugin)

    #for update_db
    pointer    = flexmock('pointer', :creator => nil)
    flexmock(pointer, :+ => pointer)
    substance = flexmock('substance', 
                         :pointer                => pointer,
                         :cyp450substrate        => substrate1,
                         :substrate_connections  => [connection], 
                         :primary_connection_key => 'primary_connection_key'
                        )
    cyp450 = flexmock('cyp450', 
                      :cyp_id     => 'cyp_id',
                      :pointer    => pointer,
                      :inhibitors => {'key' => substrate1},
                      :inducers   => {'key' => substrate1}
                     )
    flexmock(@app, 
             :cyp450 => cyp450,
             :update => nil,
             :delete => nil,
             :substance_by_connection_key => substance)

    expected = {substance => [connection]}
    assert_equal(expected, @plugin.update)
  end
  def test_flock_conn_name__equal
    flock_conn = flexmock('flock_conn', :name => 'name=')
    assert_equal('name', @plugin.flock_conn_name(flock_conn))
  end
  def test_flock_conn_name__else
    flock_conn = flexmock('flock_conn', :name => 'name')
    assert_equal('name', @plugin.flock_conn_name(flock_conn))
  end
  def test_format_connection_key
    flexmock(ODDB::Interaction::InteractionPlugin::Substance) do |s|
      s.should_receive(:format_connection_key).and_return('key')
    end
    assert_equal('key', @plugin.format_connection_key('key'))
  end
  def test_merge_data
    substance = flexmock('substance', :same_as? => true)
    flexmock(@app, :substance => substance)
    substrate = flexmock('substrate', 
                         :name        => 'name',
                         :auc_factor  => nil,
                         :auc_factor= => nil,
                         :category    => nil,
                         :category=   => nil,
                         :links       => []
                        )
    cyt = flexmock('cyt', 
                   :substrates     => [substrate],
                   :add_connection => nil,
                   :inhibitors     => [substrate],
                   :inducers       => [substrate]
                  )
    hayes     = {'cyt_id' => cyt}
    flockhart = {'cyt_id' => cyt}
    expected  = {'cyt_id' => cyt}
    assert_equal(expected, @plugin.merge_data(hayes, flockhart))
  end
  def test_merge_data__same_as_false
    substance = flexmock('substance', :same_as? => false)
    flexmock(@app, :substance => substance)
    substrate = flexmock('substrate', 
                         :name        => 'name',
                         :auc_factor  => nil,
                         :auc_factor= => nil,
                         :category    => nil,
                         :category=   => nil,
                         :links       => []
                        )
    cyt = flexmock('cyt', 
                   :substrates     => [substrate],
                   :add_connection => nil,
                   :inhibitors     => [substrate],
                   :inducers       => [substrate]
                  )
    hayes     = {'cyt_id' => cyt}
    flockhart = {'cyt_id' => cyt}
    expected  = {'cyt_id' => cyt}
    assert_equal(expected, @plugin.merge_data(hayes, flockhart))
  end

  def test_merge_data__flockhart_else
    substance = flexmock('substance', :same_as? => true)
    flexmock(@app, :substance => substance)
    substrate = flexmock('substrate', 
                         :name        => 'name',
                         :auc_factor  => nil,
                         :auc_factor= => nil,
                         :category    => nil,
                         :category=   => nil,
                         :links       => []
                        )
    cyt = flexmock('cyt', 
                   :substrates     => [substrate],
                   :add_connection => nil,
                   :inhibitors     => [substrate],
                   :inducers       => [substrate]
                  )
    hayes     = {'cyt_id' => cyt}
    flockhart = {}
    expected  = {'cyt_id' => cyt}
    assert_equal(expected, @plugin.merge_data(hayes, flockhart))
  end
  def test_parse_flockhart
    substrate1 = flexmock('substrate1', 
                         :name        => 'name1',
                         :auc_factor  => nil,
                         :auc_factor= => nil,
                         :category    => nil,
                         :category=   => nil
                        )
    substrate2 = flexmock('substrate2', 
                         :name        => 'name2',
                         :auc_factor  => nil,
                         :auc_factor= => nil,
                         :category    => nil,
                         :category=   => nil
                        )
    cyt = flexmock('cyt', 
                   :substrates => [substrate1],
                   :inhibitors     => [substrate1],
                   :inducers       => [substrate2]
                  )
    plugin = flexmock('plugin',
                     :parse_table         => {'cyt_id' => cyt},
                     :parse_detail_pages  => {'cyt_id' => cyt}
                     )
    expected  = {'cyt_id' => cyt}
    assert_equal(expected, @plugin.parse_flockhart(plugin))
  end
  def test_parse_flockhart__else
    substrate1 = flexmock('substrate1', 
                         :name        => 'name1',
                         :auc_factor  => nil,
                         :auc_factor= => nil,
                         :category    => nil,
                         :category=   => nil
                        )
    substrate2 = flexmock('substrate2', 
                         :name        => 'name2',
                         :auc_factor  => nil,
                         :auc_factor= => nil,
                         :category    => nil,
                         :category=   => nil
                        )
    substrate3 = flexmock('substrate3', 
                         :name        => 'name3',
                         :auc_factor  => nil,
                         :auc_factor= => nil,
                         :category    => nil,
                         :category=   => nil
                        )
    cyt1 = flexmock('cyt', 
                   :substrates => [substrate1],
                   :inhibitors     => [substrate1],
                   :inducers       => [substrate2]
                  )
    cyt2 = flexmock('cyt', 
                   :substrates => [substrate3],
                   :inhibitors     => [substrate3],
                   :inducers       => [substrate3]
                  )

    plugin = flexmock('plugin',
                     :parse_table         => {'cyt_id' => cyt2},
                     :parse_detail_pages  => {'cyt_id' => cyt1}
                     )
    expected  = {'cyt_id' => cyt1}
    assert_equal(expected, @plugin.parse_flockhart(plugin))
  end

  def test_update_oddb_tidy_up
    flexmock(@app, :delete => nil)
    connection = flexmock('connection')
    pointer = flexmock('pointer', :+ => nil)
    substance = flexmock('substance', :pointer => pointer)
    updated_substances = {substance => [connection]}
    @plugin.instance_eval('@updated_substances = updated_substances')
    expected = updated_substances
    assert_equal(expected, @plugin.update_oddb_tidy_up)
  end
end

class TestFlockhartPlugin < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @app = flexmock 'app'
    @plugin = ODDB::Interaction::FlockhartPlugin.new @app, false
  end
  def setup_mechanize mapping=[]
    agent = flexmock Mechanize.new
    mapping.each do |page, method, url, formname, page2|
      path = File.join @datadir, page
      page = setup_page url, path, agent
      if formname
        form = flexmock page.form(formname)
        action = form.action
        page = flexmock page
        page.should_receive(:form).with(formname).and_return(form)
        path2 = File.join @datadir, page2
        page2 = setup_page action, path2, agent
        form.should_receive(:submit).and_return page2
      end
      agent.should_receive(method).with(url).and_return(page)
    end
    agent
  end
  def setup_page url, path, agent
    response = {'content-type' => 'text/html'}
    Mechanize::Page.new(URI.parse(url), response,
                        File.read(path), 200, agent)
  end
  def test_parse_detail
    path = File.expand_path('../data/html/interaction/flockhart/3A457.htm',
                            File.dirname(__FILE__))
    page = setup_page 'url', path, setup_mechanize
    cytochrome = @plugin.parse_detail_page '3A457', page
    assert_instance_of ODDB::Interaction::Cytochrome, cytochrome
    assert_equal 86, cytochrome.substrates.size
    assert_equal 31, cytochrome.inhibitors.size
    names = cytochrome.inhibitors.collect do |substr| substr.name end
    assert_equal 14, cytochrome.inducers.size
  end
end

class TestParser < Test::Unit::TestCase
  include FlexMock::TestCase
  def test_do_category
    formatter = flexmock('formatter', :end_category => 'end_category')
    parser = ODDB::Interaction::Parser.new(formatter)
    assert_equal('end_category', parser.do_category('attrs'))
  end
end

class TestFormatter < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @writer = flexmock('writer')
    @formatter = ODDB::Interaction::Formatter.new(@writer)
  end
  def test_end_category
    flexmock(@writer, :end_category => 'end_category')
    assert_equal('end_category', @formatter.end_category)
  end
  def test_push_tablerow
    flexmock(@writer, :start_tr => 'start_tr')
    tablehandler = flexmock('tablehandler', :next_row => 'next_row')
    @formatter.instance_eval('@tablehandler = tablehandler')
    attributes = {'key' => 'value'}
    assert_equal('start_tr', @formatter.push_tablerow(attributes))
  end
end

class TestCytochrome < Test::Unit::TestCase
  include FlexMock::TestCase
  def test_has_connection?
    chrome = ODDB::Interaction::Cytochrome.new('cyt_name')
    inhibitor = flexmock('inhibitor', :name => 'name')
    inhibitors = [inhibitor]
    inducer = flexmock('inducer', :name => 'name')
    inducers = [inducer]
    chrome.instance_eval('@inhibitors = inhibitors')
    chrome.instance_eval('@inducers = inducers')
    other = flexmock('other', :description => 'name')
    expected = {:inhibitor => inhibitor, :inducers => inducer}
    assert_equal(expected, chrome.has_connection?(other))
  end
end

