#!/usr/bin/env ruby
# TestBsvXmlPlugin -- oddb.org -- 10.11.2008 -- hwyss@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'plugin/bsv_xml'
require 'flexmock'

module ODDB
  class Package
  end
  class TestBsvXmlPlugin < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      @url = 'http://bag.e-mediat.net/SL2007.Web.External/File.axd?file=XMLPublications.zip'
      ODDB.config.url_bag_sl_zip = @url
      @archive = File.expand_path '../data', File.dirname(__FILE__)
      @zip = File.join @archive, 'xml', 'XMLPublications.zip'
      @app = flexmock 'app'
      @plugin = BsvXmlPlugin.new @app
      @src = <<-EOS
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<Preparations ReleaseDate="01.11.2008">
  <Preparation ProductCommercial="33">
    <NameDe>Ponstan</NameDe>
    <NameFr>Ponstan</NameFr>
    <NameIt>Ponstan</NameIt>
    <DescriptionDe>Filmtabs 500 mg </DescriptionDe>
    <DescriptionFr>filmtabs 500 mg </DescriptionFr>
    <DescriptionIt>filmtabs 500 mg </DescriptionIt>
    <AtcCode>M01AG01</AtcCode>
    <SwissmedicNo5>39271</SwissmedicNo5>
    <FlagItLimitation>Y</FlagItLimitation>
    <OrgGenCode>O</OrgGenCode>
    <FlagSB20>N</FlagSB20>
    <CommentDe />
    <CommentFr />
    <CommentIt />
    <Packs>
      <Pack Pharmacode="703279" PackId="8853" ProductKey="33">
        <DescriptionDe>12 Stk</DescriptionDe>
        <DescriptionFr>12 pce</DescriptionFr>
        <DescriptionIt>12 pce</DescriptionIt>
        <SwissmedicCategory>B</SwissmedicCategory>
        <SwissmedicNo8>39271028</SwissmedicNo8>
        <FlagNarcosis>N</FlagNarcosis>
        <FlagModal>N</FlagModal>
        <BagDossierNo>12495</BagDossierNo>
        <Limitations />
        <PointLimitations />
        <Prices>
          <ExFactoryPrice>
            <Price>2.9</Price>
            <ValidFromDate>01.08.2006</ValidFromDate>
            <Division />
            <DivisionPriveIncVat />
            <DivisionDescription />
            <PriceTypeCode>PEXF</PriceTypeCode>
            <PriceTypeDescriptionDe>Ex-Factory Preis</PriceTypeDescriptionDe>
            <PriceTypeDescriptionFr>Prix ex-factory</PriceTypeDescriptionFr>
            <PriceTypeDescriptionIt>Prix ex-factory</PriceTypeDescriptionIt>
            <PriceChangeTypeCode>NORMAL</PriceChangeTypeCode>
            <PriceChangeTypeDescriptionDe>Normale Preismutation</PriceChangeTypeDescriptionDe>
            <PriceChangeTypeDescriptionFr>Mutation de prix normale</PriceChangeTypeDescriptionFr>
            <PriceChangeTypeDescriptionIt>Mutation de prix normale</PriceChangeTypeDescriptionIt>
          </ExFactoryPrice>
          <PublicPrice>
            <Price>7.5</Price>
            <ValidFromDate>01.08.2006</ValidFromDate>
            <Division />
            <DivisionPriveIncVat />
            <DivisionDescription />
            <PriceTypeCode>PPUB</PriceTypeCode>
            <PriceTypeDescriptionDe>Publikumspreis</PriceTypeDescriptionDe>
            <PriceTypeDescriptionFr>Prix public</PriceTypeDescriptionFr>
            <PriceTypeDescriptionIt>Prix public</PriceTypeDescriptionIt>
            <PriceChangeTypeCode>NORMAL</PriceChangeTypeCode>
            <PriceChangeTypeDescriptionDe>Normale Preismutation</PriceChangeTypeDescriptionDe>
            <PriceChangeTypeDescriptionFr>Mutation de prix normale</PriceChangeTypeDescriptionFr>
            <PriceChangeTypeDescriptionIt>Mutation de prix normale</PriceChangeTypeDescriptionIt>
          </PublicPrice>
        </Prices>
        <Partners>
          <Partner>
            <PartnerType>V</PartnerType>
            <Description>Pfizer AG</Description>
            <Street>Schärenmoosstrasse 99</Street>
            <ZipCode>8052</ZipCode>
            <Place>Zürich</Place>
            <Phone>043/495 71 11</Phone>
          </Partner>
        </Partners>
        <Status>
          <IntegrationDate>15.03.1977</IntegrationDate>
          <ValidFromDate>15.03.1977</ValidFromDate>
          <ValidThruDate>31.12.9999</ValidThruDate>
          <StatusTypeCodeSl>0</StatusTypeCodeSl>
          <StatusTypeDescriptionSl>Initialzustand</StatusTypeDescriptionSl>
          <FlagApd>N</FlagApd>
        </Status>
      </Pack>
    </Packs>
    <Substances>
      <Substance>
        <DescriptionLa>Acidum mefenamicum</DescriptionLa>
        <Quantity>500</Quantity>
        <QuantityUnit>mg</QuantityUnit>
      </Substance>
    </Substances>
    <Limitations />
    <ItCodes>
      <ItCode Code="07.">
        <DescriptionDe>STOFFWECHSEL</DescriptionDe>
        <DescriptionFr>METABOLISME</DescriptionFr>
        <DescriptionIt>METABOLISME</DescriptionIt>
        <Limitations />
      </ItCode>
      <ItCode Code="07.10.">
        <DescriptionDe>Arthritis und rheumatische Krankheiten</DescriptionDe>
        <DescriptionFr>Arthrites et affections rhumatismales</DescriptionFr>
        <DescriptionIt>Arthrites et affections rhumatismales</DescriptionIt>
        <Limitations />
      </ItCode>
      <ItCode Code="07.10.10.">
        <DescriptionDe>Einfache entzündungshemmende Mittel </DescriptionDe>
        <DescriptionFr>Anti-inflammatoires simples </DescriptionFr>
        <DescriptionIt>Anti-inflammatoires simples </DescriptionIt>
        <Limitations />
      </ItCode>
    </ItCodes>
    <Status>
      <IntegrationDate>15.03.1977</IntegrationDate>
      <ValidFromDate>15.03.1977</ValidFromDate>
      <ValidThruDate>31.12.9999</ValidThruDate>
      <StatusTypeCodeSl>0</StatusTypeCodeSl>
      <StatusTypeDescriptionSl>Initialzustand</StatusTypeDescriptionSl>
      <FlagApd>N</FlagApd>
    </Status>
  </Preparation>
</Preparations>
       EOS
      @conflicted_src = <<-EOS
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<Preparations ReleaseDate="01.11.2008">
  <Preparation ProductCommercial="33">
    <NameDe>Ponstan</NameDe>
    <NameFr>Ponstan</NameFr>
    <NameIt>Ponstan</NameIt>
    <DescriptionDe>Filmtabs 500 mg </DescriptionDe>
    <DescriptionFr>filmtabs 500 mg </DescriptionFr>
    <DescriptionIt>filmtabs 500 mg </DescriptionIt>
    <AtcCode>M01AG01</AtcCode>
    <SwissmedicNo5>12345</SwissmedicNo5>
    <FlagItLimitation>Y</FlagItLimitation>
    <OrgGenCode>O</OrgGenCode>
    <FlagSB20>N</FlagSB20>
    <CommentDe />
    <CommentFr />
    <CommentIt />
    <Packs>
      <Pack Pharmacode="703279" PackId="8853" ProductKey="33">
        <DescriptionDe>12 Stk</DescriptionDe>
        <DescriptionFr>12 pce</DescriptionFr>
        <DescriptionIt>12 pce</DescriptionIt>
        <SwissmedicCategory>B</SwissmedicCategory>
        <SwissmedicNo8>39271028</SwissmedicNo8>
        <FlagNarcosis>N</FlagNarcosis>
        <FlagModal>N</FlagModal>
        <BagDossierNo>12495</BagDossierNo>
        <Limitations />
        <PointLimitations />
        <Prices>
          <ExFactoryPrice>
            <Price>2.9</Price>
            <ValidFromDate>01.08.2006</ValidFromDate>
            <Division />
            <DivisionPriveIncVat />
            <DivisionDescription />
            <PriceTypeCode>PEXF</PriceTypeCode>
            <PriceTypeDescriptionDe>Ex-Factory Preis</PriceTypeDescriptionDe>
            <PriceTypeDescriptionFr>Prix ex-factory</PriceTypeDescriptionFr>
            <PriceTypeDescriptionIt>Prix ex-factory</PriceTypeDescriptionIt>
            <PriceChangeTypeCode>NORMAL</PriceChangeTypeCode>
            <PriceChangeTypeDescriptionDe>Normale Preismutation</PriceChangeTypeDescriptionDe>
            <PriceChangeTypeDescriptionFr>Mutation de prix normale</PriceChangeTypeDescriptionFr>
            <PriceChangeTypeDescriptionIt>Mutation de prix normale</PriceChangeTypeDescriptionIt>
          </ExFactoryPrice>
          <PublicPrice>
            <Price>7.5</Price>
            <ValidFromDate>01.08.2006</ValidFromDate>
            <Division />
            <DivisionPriveIncVat />
            <DivisionDescription />
            <PriceTypeCode>PPUB</PriceTypeCode>
            <PriceTypeDescriptionDe>Publikumspreis</PriceTypeDescriptionDe>
            <PriceTypeDescriptionFr>Prix public</PriceTypeDescriptionFr>
            <PriceTypeDescriptionIt>Prix public</PriceTypeDescriptionIt>
            <PriceChangeTypeCode>NORMAL</PriceChangeTypeCode>
            <PriceChangeTypeDescriptionDe>Normale Preismutation</PriceChangeTypeDescriptionDe>
            <PriceChangeTypeDescriptionFr>Mutation de prix normale</PriceChangeTypeDescriptionFr>
            <PriceChangeTypeDescriptionIt>Mutation de prix normale</PriceChangeTypeDescriptionIt>
          </PublicPrice>
        </Prices>
        <Partners>
          <Partner>
            <PartnerType>V</PartnerType>
            <Description>Pfizer AG</Description>
            <Street>Schärenmoosstrasse 99</Street>
            <ZipCode>8052</ZipCode>
            <Place>Zürich</Place>
            <Phone>043/495 71 11</Phone>
          </Partner>
        </Partners>
        <Status>
          <IntegrationDate>15.03.1977</IntegrationDate>
          <ValidFromDate>15.03.1977</ValidFromDate>
          <ValidThruDate>31.12.9999</ValidThruDate>
          <StatusTypeCodeSl>0</StatusTypeCodeSl>
          <StatusTypeDescriptionSl>Initialzustand</StatusTypeDescriptionSl>
          <FlagApd>N</FlagApd>
        </Status>
      </Pack>
    </Packs>
    <Substances>
      <Substance>
        <DescriptionLa>Acidum mefenamicum</DescriptionLa>
        <Quantity>500</Quantity>
        <QuantityUnit>mg</QuantityUnit>
      </Substance>
    </Substances>
    <Limitations />
    <ItCodes>
      <ItCode Code="07.">
        <DescriptionDe>STOFFWECHSEL</DescriptionDe>
        <DescriptionFr>METABOLISME</DescriptionFr>
        <DescriptionIt>METABOLISME</DescriptionIt>
        <Limitations />
      </ItCode>
      <ItCode Code="07.10.">
        <DescriptionDe>Arthritis und rheumatische Krankheiten</DescriptionDe>
        <DescriptionFr>Arthrites et affections rhumatismales</DescriptionFr>
        <DescriptionIt>Arthrites et affections rhumatismales</DescriptionIt>
        <Limitations />
      </ItCode>
      <ItCode Code="07.10.10.">
        <DescriptionDe>Einfache entzündungshemmende Mittel </DescriptionDe>
        <DescriptionFr>Anti-inflammatoires simples </DescriptionFr>
        <DescriptionIt>Anti-inflammatoires simples </DescriptionIt>
        <Limitations />
      </ItCode>
    </ItCodes>
    <Status>
      <IntegrationDate>15.03.1977</IntegrationDate>
      <ValidFromDate>15.03.1977</ValidFromDate>
      <ValidThruDate>31.12.9999</ValidThruDate>
      <StatusTypeCodeSl>0</StatusTypeCodeSl>
      <StatusTypeDescriptionSl>Initialzustand</StatusTypeDescriptionSl>
      <FlagApd>N</FlagApd>
    </Status>
  </Preparation>
</Preparations>
       EOS
    end
    def test_download
      target = File.join @archive, 'xml',
               Date.today.strftime("XMLPublications-%Y.%m.%d.zip")
      page = flexmock 'page'
      page.should_receive(:save_as).with(target).times(1).and_return do
        FileUtils.cp @zip, target
      end
      session = flexmock 'session'
      session.should_receive(:get).times(1).with(@url).and_return page
      mech = flexmock WWW::Mechanize
      mech.should_receive(:new).times(1).and_return session
      archive = File.expand_path 'var', File.dirname(__FILE__)
      result = nil
      assert_nothing_raised do 
        result = @plugin.download_to @archive
      end
      assert_equal target, result
      assert File.exist?(target), "download to #{target} failed."
    ensure
      FileUtils.rm_r archive if File.exists? archive
    end
    def test_update_it_codes
      updates = []
      @app.should_receive(:update).times(52).and_return do |ptr, data|
        updates.push data
      end
      zip = Zip::ZipFile.open(@zip)
      zip.find_entry('ItCodes.xml').get_input_stream do |io|
        @plugin.update_it_codes io
      end
      expected = {
        :de => "NERVENSYSTEM", 
        :fr => "SYSTEME NERVEUX",
        :it => "SYSTEME NERVEUX", 
      }
      ith = updates.at(1)
      assert_equal expected, ith
      de = Text::Chapter.new
      pr = de.next_section.next_paragraph
      pr << "Gesamthaft zugelassen "
      pr.augment_format(:bold)
      pr << '120'
      pr.reduce_format(:bold)
      pr << " Punkte. "
      pr.augment_format(:bold)
      pr << "Iniectabilia sine limitatione"
      fr = Text::Chapter.new
      pr = fr.next_section.next_paragraph
      pr << "Prescription limit\351e au maximum \340 "
      pr.augment_format(:bold)
      pr << "120"
      pr.reduce_format(:bold)
      pr << " points. "
      pr.augment_format(:bold)
      pr << "Iniectabilia sine limitatione"
      it = Text::Chapter.new
      pr = it.next_section.next_paragraph
      pr << "Ammessi in totale "
      pr.augment_format(:bold)
      pr << "120"
      pr.reduce_format(:bold)
      pr << " punti. "
      pr.augment_format(:bold)
      pr << "Iniectabilia sine limitatione"
      expected = {
        :code       => "120PISL",
        :de         => de,
        :fr         => fr,
        :it         => it,
        :niveau     => "IP",
        :type       => "PKT",
        :valid_from => Date.new(2000),
        :value      => "120",
      }
      ith = updates.at(10)
      assert_equal expected, ith
    end
    def test_update_preparation__unknown_registration__out_of_trade
      updates = []
      flexmock(Package).should_receive(:find_by_pharmacode).
                        times(1).and_return nil
      setup_meddata_server
      @app.should_receive(:registration).and_return nil
      @plugin.update_preparations StringIO.new(@src)
      assert_equal [], updates
      assert_equal({}, @plugin.change_flags)
      listener = @plugin.preparations_listener
      assert_equal [], listener.conflicted_packages
      assert_equal [], listener.conflicted_registrations
      assert_equal [], listener.unknown_packages
      assert_equal [], listener.unknown_registrations
    end
    def test_update_preparation__unknown_registration
      updates = []
      flexmock(Package).should_receive(:find_by_pharmacode).
                        times(1).and_return nil
      setup_meddata_server :ean13 => '7680392710281'
      @app.should_receive(:registration).and_return nil
      @plugin.update_preparations StringIO.new(@src)
      assert_equal [], updates
      assert_equal({}, @plugin.change_flags)
      listener = @plugin.preparations_listener
      assert_equal [], listener.conflicted_packages
      assert_equal [], listener.conflicted_registrations
      expected = []
      assert_equal expected, listener.unknown_packages
      expected = [ {
        :name_base          => "Ponstan",
        :name_descr         => "Filmtabs 500 mg ",
        :swissmedic_no5_bag => "39271",
      } ]
      assert_equal expected, listener.unknown_registrations
    end
    def test_update_preparation__conflicted_registration
      reg = setup_registration :iksnr => '39271'
      package = setup_package :pharmacode => "703279", :registration => reg, 
                              :steps => %w{39271 02 028}, 
                              :price_public => Util::Money.new(17.65), 
                              :price_exfactory => Util::Money.new(11.22)
      flexmock(Package).should_receive(:find_by_pharmacode).
                        times(1).and_return package
      setup_meddata_server
      @app.should_receive(:registration).and_return reg
      expected_updates = {}
      ptr = Persistence::Pointer.new [:registration, '39271']
      expected_updates.store ptr, { :generic_type => :original }
      ptr += [:sequence, '02']
      expected_updates.store ptr, { :atc_class => 'M01AG01' }
      pac_pointer = ptr += [:package, '028']
      data = { 
        :price_exfactory => Util::Money.new(2.9),
        :sl_generic_type => :original,
        :deductible      => 10,
        :price_public    => Util::Money.new(7.5),
        :narcotic        => false,
        :pharmacode      => '703279',
      }
      expected_updates.store ptr, data
      ptr += :sl_entry
      data = { 
        :bsv_dossier       => "12495",
        :valid_until       => Date.new(9999,12,31),
        :status            => "0",
        :valid_from        => Date.new(1977,3,15),
        :introduction_date => Date.new(1977,3,15),
        :limitation_points => nil,
      }
      expected_updates.store ptr.creator, data
      @app.should_receive(:update).and_return do |ptr, data|
        assert_equal expected_updates.delete(ptr), data, ptr.to_s
      end
      @plugin.update_preparations StringIO.new(@conflicted_src)
      assert_equal({}, expected_updates)
      assert_equal({pac_pointer => [:price_cut]}, @plugin.change_flags)
      listener = @plugin.preparations_listener
      assert_equal [], listener.conflicted_packages
      expected = [ {
        :name_base          => "Ponstan",
        :name_descr         => "Filmtabs 500 mg ",
        :swissmedic_no_oddb => "39271",
        :swissmedic_no5_bag => "12345",
        :swissmedic_no8_bag => "39271028",
        :pharmacode_bag     => "703279",
        :generic_type       => :original,
        :deductible         => 10,
        :atc_class          => "M01AG01",
      } ]
      assert_equal expected, listener.conflicted_registrations
      assert_equal [], listener.unknown_packages
      expected = []
      assert_equal [], listener.unknown_registrations
    end
    def test_update_preparation__unknown_package__out_of_trade
      reg = setup_registration :iksnr => '39271'
      flexmock(Package).should_receive(:find_by_pharmacode).
                        times(1).and_return nil
      setup_meddata_server
      @app.should_receive(:registration).and_return reg
      expected_updates = {}
      ptr = Persistence::Pointer.new [:registration, '39271']
      expected_updates.store ptr, { :generic_type => :original }
      @app.should_receive(:update).times(1).and_return do |ptr, data|
        assert_equal expected_updates.delete(ptr), data
      end
      @plugin.update_preparations StringIO.new(@conflicted_src)
      assert_equal({}, expected_updates)
      assert_equal({}, @plugin.change_flags)
      listener = @plugin.preparations_listener
      assert_equal [], listener.conflicted_packages
      assert_equal [], listener.conflicted_registrations
      assert_equal [], listener.unknown_packages
      expected = []
      assert_equal [], listener.unknown_registrations
    end
    def test_update_preparation__unknown_package
      reg = setup_registration :iksnr => '39271'
      flexmock(Package).should_receive(:find_by_pharmacode).
                        times(1).and_return nil
      setup_meddata_server :ean13 => '7680392710281'
      @app.should_receive(:registration).and_return reg
      expected_updates = {}
      ptr = Persistence::Pointer.new [:registration, '39271']
      expected_updates.store ptr, { :generic_type => :original }
      @app.should_receive(:update).times(1).and_return do |ptr, data|
        assert_equal expected_updates.delete(ptr), data
      end
      @plugin.update_preparations StringIO.new(@src)
      assert_equal({}, expected_updates)
      assert_equal({}, @plugin.change_flags)
      listener = @plugin.preparations_listener
      assert_equal [], listener.conflicted_packages
      assert_equal [], listener.conflicted_registrations
      expected = [ {
        :name_base          => "Ponstan",
        :name_descr         => "Filmtabs 500 mg ",
        :swissmedic_no5_bag => "39271",
        :swissmedic_no8_bag => "39271028",
        :pharmacode_bag     => "703279",
        :generic_type       => :original,
        :deductible         => 10,
        :atc_class          => "M01AG01",
      } ]
      assert_equal expected, listener.unknown_packages
      expected = []
      assert_equal [], listener.unknown_registrations
    end
    def test_update_preparation__conflicted_package
      package = setup_package :pharmacode => "987654",
                              :steps => %w{39271 02 028}, 
                              :price_public => Util::Money.new(17.65), 
                              :price_exfactory => Util::Money.new(11.22)
      reg = setup_registration :iksnr => '39271', :package => package
      package.should_receive(:registration).and_return reg
      flexmock(Package).should_receive(:find_by_pharmacode).
                        times(1).and_return nil
      setup_meddata_server :ean13 => '7680392710281'
      @app.should_receive(:registration).and_return reg
      expected_updates = {}
      ptr = Persistence::Pointer.new [:registration, '39271']
      expected_updates.store ptr, { :generic_type => :original }
      ptr += [:sequence, '02']
      pac_pointer = ptr += [:package, '028']
      @app.should_receive(:update).and_return do |ptr, data|
        assert_equal expected_updates.delete(ptr), data
      end
      @plugin.update_preparations StringIO.new(@conflicted_src)
      assert_equal({}, expected_updates)
      assert_equal({}, @plugin.change_flags)
      listener = @plugin.preparations_listener
      expected = [ {
        :name_base          => "Ponstan",
        :name_descr         => "Filmtabs 500 mg ",
        :swissmedic_no5_bag => "12345",
        :swissmedic_no8_bag => "39271028",
        :pharmacode_bag     => "703279",
        :pharmacode_oddb    => "987654",
        :generic_type       => :original,
        :deductible         => 10,
        :atc_class          => "M01AG01",
      } ]
      assert_equal expected, listener.conflicted_packages
      assert_equal [], listener.conflicted_registrations
      assert_equal [], listener.unknown_packages
      expected = []
      assert_equal [], listener.unknown_registrations
    end
    def test_update_preparation
      reg = setup_registration :iksnr => '39271'
      package = setup_package :pharmacode => "703279", :registration => reg, 
                              :steps => %w{39271 02 028}, 
                              :price_public => Util::Money.new(17.65), 
                              :price_exfactory => Util::Money.new(11.22)
      flexmock(Package).should_receive(:find_by_pharmacode).
                        times(1).and_return package
      setup_meddata_server
      @app.should_receive(:registration).and_return reg
      expected_updates = {}
      ptr = Persistence::Pointer.new [:registration, '39271']
      expected_updates.store ptr, { :generic_type => :original }
      ptr += [:sequence, '02']
      expected_updates.store ptr, { :atc_class => 'M01AG01' }
      pac_pointer = ptr += [:package, '028']
      data = { 
        :price_exfactory => Util::Money.new(2.9),
        :sl_generic_type => :original,
        :deductible      => 10,
        :price_public    => Util::Money.new(7.5),
        :narcotic        => false,
        :pharmacode      => '703279',
      }
      expected_updates.store ptr, data
      ptr += :sl_entry
      data = { 
        :bsv_dossier       => "12495",
        :valid_until       => Date.new(9999,12,31),
        :status            => "0",
        :valid_from        => Date.new(1977,3,15),
        :introduction_date => Date.new(1977,3,15),
        :limitation_points => nil,
      }
      expected_updates.store ptr.creator, data
      @app.should_receive(:update).and_return do |ptr, data|
        assert_equal expected_updates.delete(ptr), data
      end
      @plugin.update_preparations StringIO.new(@src)
      assert_equal({}, expected_updates)
      assert_equal({pac_pointer => [:price_cut]}, @plugin.change_flags)
      listener = @plugin.preparations_listener
      assert_equal [], listener.conflicted_packages
      assert_equal [], listener.conflicted_registrations
      assert_equal [], listener.unknown_packages
      expected = []
      assert_equal [], listener.unknown_registrations
    end
    def setup_package opts={}
      pack = flexmock opts
      sequence = flexmock opts
      if steps = opts[:steps]
        iksnr, seqnr, pacnr = steps
        ptr = Persistence::Pointer.new [:registration, iksnr], [:sequence, seqnr]
        sequence.should_receive(:pointer).and_return(ptr)
        pack.should_receive(:pointer).and_return(ptr + [:package, pacnr])  
        if reg = opts[:registration]
          reg.should_receive(:sequence).with(seqnr).and_return(sequence)
          reg.should_receive(:package).with(pacnr).and_return(pack)
          sequence.should_receive(:package).with(pacnr).and_return(pack)
        end
      end
      pack.should_receive(:sequence).and_return sequence
      pack.should_ignore_missing
      pack
    end
    def setup_registration opts={}
      reg = flexmock opts
      ptr = Persistence::Pointer.new([:registration, opts[:iksnr]])
      reg.should_receive(:pointer).and_return ptr
      reg.should_receive(:package).and_return do |ikscd|
        (packs = opts[:packages]) && packs[ikscd]
      end
      reg
    end
    def setup_meddata_server opts={}
      server = flexmock(BsvXmlPlugin::PreparationsListener::MEDDATA_SERVER)
      session = flexmock 'session'
      server.should_receive(:session).and_return do |type, block|
        assert_equal :product, type
        block.call session
      end
      session.should_receive(:search).and_return ['meddata-result']
      session.should_receive(:detail).and_return opts
    end
  end
end
