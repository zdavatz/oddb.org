#!/usr/bin/env ruby
# TestBsvXmlPlugin -- oddb.org -- 10.11.2008 -- hwyss@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'stub/odba'
require 'plugin/bsv_xml'
require 'flexmock'
require 'src/util/logfile'

module ODDB
  class BsvXmlPlugin
    class PreparationsListener
    end
  end
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
      @lim_txt_src = <<-EOS
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<Preparations ReleaseDate="01.04.2010">
  <Preparation ProductCommercial="1018817">
    <NameDe>Reminyl Prolonged Release</NameDe>
    <NameFr>Reminyl Prolonged Release</NameFr>
    <NameIt>Reminyl Prolonged Release</NameIt>
    <DescriptionDe>Kaps 16 mg </DescriptionDe>
    <DescriptionFr>caps 16 mg </DescriptionFr>
    <DescriptionIt>caps 16 mg </DescriptionIt>
    <AtcCode>N06DA04</AtcCode>
    <SwissmedicNo5>56754</SwissmedicNo5>
    <FlagItLimitation>Y</FlagItLimitation>
    <OrgGenCode />
    <FlagSB20>N</FlagSB20>
    <CommentDe />
    <CommentFr />
    <CommentIt />
    <Packs>
      <Pack Pharmacode="2993471" PackId="14722" ProductKey="1018817">
        <DescriptionDe>28 Stk</DescriptionDe>
        <DescriptionFr>28 pce</DescriptionFr>
        <DescriptionIt>28 pce</DescriptionIt>
        <SwissmedicCategory>B</SwissmedicCategory>
        <SwissmedicNo8>56754007</SwissmedicNo8>
        <FlagNarcosis>N</FlagNarcosis>
        <FlagModal />
        <BagDossierNo>18168</BagDossierNo>
        <Limitations />
        <PointLimitations />
        <Prices>
          <ExFactoryPrice>
            <Price>125.8359</Price>
            <ValidFromDate>01.03.2010</ValidFromDate>
            <Division />
            <DivisionPriveIncVat />
            <DivisionDescription />
            <PriceTypeCode>PEXF</PriceTypeCode>
            <PriceTypeDescriptionDe>Ex-Factory Preis</PriceTypeDescriptionDe>
            <PriceTypeDescriptionFr>Prix ex-factory</PriceTypeDescriptionFr>
            <PriceTypeDescriptionIt>Prix ex-factory</PriceTypeDescriptionIt>
            <PriceChangeTypeCode>AUSLANDPV</PriceChangeTypeCode>
            <PriceChangeTypeDescriptionDe>Auslandspreisvergleich</PriceChangeTypeDescriptionDe>
            <PriceChangeTypeDescriptionFr>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionFr>
            <PriceChangeTypeDescriptionIt>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionIt>
          </ExFactoryPrice>
          <PublicPrice>
            <Price>160.7</Price>
            <ValidFromDate>01.03.2010</ValidFromDate>
            <Division />
            <DivisionPriveIncVat />
            <DivisionDescription />
            <PriceTypeCode>PPUB</PriceTypeCode>
            <PriceTypeDescriptionDe>Publikumspreis</PriceTypeDescriptionDe>
            <PriceTypeDescriptionFr>Prix public</PriceTypeDescriptionFr>
            <PriceTypeDescriptionIt>Prix public</PriceTypeDescriptionIt>
            <PriceChangeTypeCode>AUSLANDPV</PriceChangeTypeCode>
            <PriceChangeTypeDescriptionDe>Auslandspreisvergleich</PriceChangeTypeDescriptionDe>
            <PriceChangeTypeDescriptionFr>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionFr>
            <PriceChangeTypeDescriptionIt>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionIt>
          </PublicPrice>
        </Prices>
        <Partners>
          <Partner>
            <PartnerType>V</PartnerType>
            <Description>Janssen-Cilag AG</Description>
            <Street>Sihlbruggstrasse 111</Street>
            <ZipCode>6341</ZipCode>
            <Place>Baar</Place>
            <Phone>041/767 34 34</Phone>
          </Partner>
        </Partners>
        <Status>
          <IntegrationDate>01.07.2005</IntegrationDate>
          <ValidFromDate>01.07.2005</ValidFromDate>
          <ValidThruDate>31.12.9999</ValidThruDate>
          <StatusTypeCodeSl>0</StatusTypeCodeSl>
          <StatusTypeDescriptionSl>Initialzustand</StatusTypeDescriptionSl>
          <FlagApd>N</FlagApd>
        </Status>
      </Pack>
      <Pack Pharmacode="" PackId="14723" ProductKey="1018817">
        <DescriptionDe>84 Stk</DescriptionDe>
        <DescriptionFr>84 pce</DescriptionFr>
        <DescriptionIt>84 pce</DescriptionIt>
        <SwissmedicCategory>B</SwissmedicCategory>
        <SwissmedicNo8>56754015</SwissmedicNo8>
        <FlagNarcosis>N</FlagNarcosis>
        <FlagModal>Y</FlagModal>
        <BagDossierNo>18168</BagDossierNo>
        <Limitations />
        <PointLimitations />
        <Prices>
          <ExFactoryPrice>
            <Price>377.5076</Price>
            <ValidFromDate>01.03.2010</ValidFromDate>
            <Division />
            <DivisionPriveIncVat />
            <DivisionDescription />
            <PriceTypeCode>PEXF</PriceTypeCode>
            <PriceTypeDescriptionDe>Ex-Factory Preis</PriceTypeDescriptionDe>
            <PriceTypeDescriptionFr>Prix ex-factory</PriceTypeDescriptionFr>
            <PriceTypeDescriptionIt>Prix ex-factory</PriceTypeDescriptionIt>
            <PriceChangeTypeCode>AUSLANDPV</PriceChangeTypeCode>
            <PriceChangeTypeDescriptionDe>Auslandspreisvergleich</PriceChangeTypeDescriptionDe>
            <PriceChangeTypeDescriptionFr>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionFr>
            <PriceChangeTypeDescriptionIt>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionIt>
          </ExFactoryPrice>
          <PublicPrice>
            <Price>449.35</Price>
            <ValidFromDate>01.03.2010</ValidFromDate>
            <Division />
            <DivisionPriveIncVat />
            <DivisionDescription />
            <PriceTypeCode>PPUB</PriceTypeCode>
            <PriceTypeDescriptionDe>Publikumspreis</PriceTypeDescriptionDe>
            <PriceTypeDescriptionFr>Prix public</PriceTypeDescriptionFr>
            <PriceTypeDescriptionIt>Prix public</PriceTypeDescriptionIt>
            <PriceChangeTypeCode>AUSLANDPV</PriceChangeTypeCode>
            <PriceChangeTypeDescriptionDe>Auslandspreisvergleich</PriceChangeTypeDescriptionDe>
            <PriceChangeTypeDescriptionFr>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionFr>
            <PriceChangeTypeDescriptionIt>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionIt>
          </PublicPrice>
        </Prices>
        <Partners>
          <Partner>
            <PartnerType>V</PartnerType>
            <Description>Janssen-Cilag AG</Description>
            <Street>Sihlbruggstrasse 111</Street>
            <ZipCode>6341</ZipCode>
            <Place>Baar</Place>
            <Phone>041/767 34 34</Phone>
          </Partner>
        </Partners>
        <Status>
          <IntegrationDate>01.01.2010</IntegrationDate>
          <ValidFromDate>01.01.2010</ValidFromDate>
          <ValidThruDate>31.12.9999</ValidThruDate>
          <StatusTypeCodeSl>0</StatusTypeCodeSl>
          <StatusTypeDescriptionSl>Initialzustand</StatusTypeDescriptionSl>
          <FlagApd>N</FlagApd>
        </Status>
      </Pack>
    </Packs>
    <Substances>
      <Substance>
        <DescriptionLa>Galantamini hydrobromidum</DescriptionLa>
        <Quantity />
        <QuantityUnit />
      </Substance>
    </Substances>
    <Limitations>
      <Limitation>
        <LimitationCode>THERAPIEBEG</LimitationCode>
        <LimitationType>KOM</LimitationType>
        <LimitationNiveau>IP</LimitationNiveau>
        <LimitationValue />
        <DescriptionDe>Zu Therapiebeginn Durchführung z.B. eines Minimentaltests.&lt;br&gt;
Erste Zwischenevaluation nach 3 Monaten, dann alle 6 Monate.&lt;br&gt;
Falls die MMSE1)-Werte unter 10 liegen, ist die Behandlung abzubrechen.&lt;br&gt;
Die Therapie kann nur mit einem Präparat durchgeführt werden.&lt;br&gt;

1) mini mental status examination</DescriptionDe>
        <DescriptionFr>En début de thérapie, application par ex. d'un test minimental.&lt;br&gt;
Première évaluation intermédiaire après trois mois et ensuite tous les six mois.&lt;br&gt;
Si les valeurs MMSE1) sont inférieures à 10, il y a lieu d'interrompre la prise du médicament.&lt;br&gt;
La thérapie ne peut être appliquée qu'avec une préparation.&lt;br&gt;

1) mini mental status examination</DescriptionFr>
        <DescriptionIt>All'inizio della terapia si esegue ad es. un test minimentale.&lt;br&gt;
Prima valutazione intermedia dopo 3 mesi, poi ogni 6 mesi.&lt;br&gt;
Se i valori MMSE1) sono inferiori a 10 bisogna cessare la terapia.&lt;br&gt;
La terapia può essere effettuata soltanto con un preparato.&lt;br&gt;

1) mini mental status examination</DescriptionIt>
        <ValidFromDate>01.01.2007</ValidFromDate>
        <ValidThruDate>31.12.9999</ValidThruDate>
      </Limitation>
    </Limitations>
    <ItCodes>
      <ItCode Code="01.">
        <DescriptionDe>NERVENSYSTEM</DescriptionDe>
        <DescriptionFr>SYSTEME NERVEUX</DescriptionFr>
        <DescriptionIt>SYSTEME NERVEUX</DescriptionIt>
        <Limitations />
      </ItCode>
      <ItCode Code="01.99.">
        <DescriptionDe>Varia</DescriptionDe>
        <DescriptionFr>Varia</DescriptionFr>
        <DescriptionIt>Varia</DescriptionIt>
        <Limitations />
      </ItCode>
    </ItCodes>
    <Status>
      <IntegrationDate>01.07.2005</IntegrationDate>
      <ValidFromDate>01.07.2005</ValidFromDate>
      <ValidThruDate>31.12.9999</ValidThruDate>
      <StatusTypeCodeSl>0</StatusTypeCodeSl>
      <StatusTypeDescriptionSl>Initialzustand</StatusTypeDescriptionSl>
      <FlagApd>N</FlagApd>
    </Status>
  </Preparation>
  <Preparation ProductCommercial="1018818">
    <NameDe>Reminyl Prolonged Release</NameDe>
    <NameFr>Reminyl Prolonged Release</NameFr>
    <NameIt>Reminyl Prolonged Release</NameIt>
    <DescriptionDe>Kaps 24 mg </DescriptionDe>
    <DescriptionFr>caps 24 mg </DescriptionFr>
    <DescriptionIt>caps 24 mg </DescriptionIt>
    <AtcCode>N06DA04</AtcCode>
    <SwissmedicNo5>56754</SwissmedicNo5>
    <FlagItLimitation>Y</FlagItLimitation>
    <OrgGenCode />
    <FlagSB20>N</FlagSB20>
    <CommentDe />
    <CommentFr />
    <CommentIt />
    <Packs>
      <Pack Pharmacode="2993488" PackId="14724" ProductKey="1018818">
        <DescriptionDe>28 Stk</DescriptionDe>
        <DescriptionFr>28 pce</DescriptionFr>
        <DescriptionIt>28 pce</DescriptionIt>
        <SwissmedicCategory>B</SwissmedicCategory>
        <SwissmedicNo8>56754019</SwissmedicNo8>
        <FlagNarcosis>N</FlagNarcosis>
        <FlagModal />
        <BagDossierNo>18168</BagDossierNo>
        <Limitations />
        <PointLimitations />
        <Prices>
          <ExFactoryPrice>
            <Price>125.8359</Price>
            <ValidFromDate>01.03.2010</ValidFromDate>
            <Division />
            <DivisionPriveIncVat />
            <DivisionDescription />
            <PriceTypeCode>PEXF</PriceTypeCode>
            <PriceTypeDescriptionDe>Ex-Factory Preis</PriceTypeDescriptionDe>
            <PriceTypeDescriptionFr>Prix ex-factory</PriceTypeDescriptionFr>
            <PriceTypeDescriptionIt>Prix ex-factory</PriceTypeDescriptionIt>
            <PriceChangeTypeCode>AUSLANDPV</PriceChangeTypeCode>
            <PriceChangeTypeDescriptionDe>Auslandspreisvergleich</PriceChangeTypeDescriptionDe>
            <PriceChangeTypeDescriptionFr>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionFr>
            <PriceChangeTypeDescriptionIt>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionIt>
          </ExFactoryPrice>
          <PublicPrice>
            <Price>160.7</Price>
            <ValidFromDate>01.03.2010</ValidFromDate>
            <Division />
            <DivisionPriveIncVat />
            <DivisionDescription />
            <PriceTypeCode>PPUB</PriceTypeCode>
            <PriceTypeDescriptionDe>Publikumspreis</PriceTypeDescriptionDe>
            <PriceTypeDescriptionFr>Prix public</PriceTypeDescriptionFr>
            <PriceTypeDescriptionIt>Prix public</PriceTypeDescriptionIt>
            <PriceChangeTypeCode>AUSLANDPV</PriceChangeTypeCode>
            <PriceChangeTypeDescriptionDe>Auslandspreisvergleich</PriceChangeTypeDescriptionDe>
            <PriceChangeTypeDescriptionFr>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionFr>
            <PriceChangeTypeDescriptionIt>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionIt>
          </PublicPrice>
        </Prices>
        <Partners>
          <Partner>
            <PartnerType>V</PartnerType>
            <Description>Janssen-Cilag AG</Description>
            <Street>Sihlbruggstrasse 111</Street>
            <ZipCode>6341</ZipCode>
            <Place>Baar</Place>
            <Phone>041/767 34 34</Phone>
          </Partner>
        </Partners>
        <Status>
          <IntegrationDate>01.07.2005</IntegrationDate>
          <ValidFromDate>01.07.2005</ValidFromDate>
          <ValidThruDate>31.12.9999</ValidThruDate>
          <StatusTypeCodeSl>0</StatusTypeCodeSl>
          <StatusTypeDescriptionSl>Initialzustand</StatusTypeDescriptionSl>
          <FlagApd>N</FlagApd>
        </Status>
      </Pack>
      <Pack Pharmacode="" PackId="14725" ProductKey="1018818">
        <DescriptionDe>84 Stk</DescriptionDe>
        <DescriptionFr>84 pce</DescriptionFr>
        <DescriptionIt>84 pce</DescriptionIt>
        <SwissmedicCategory>B</SwissmedicCategory>
        <SwissmedicNo8>56754029</SwissmedicNo8>
        <FlagNarcosis>N</FlagNarcosis>
        <FlagModal>Y</FlagModal>
        <BagDossierNo>18168</BagDossierNo>
        <Limitations />
        <PointLimitations />
        <Prices>
          <ExFactoryPrice>
            <Price>377.5076</Price>
            <ValidFromDate>01.03.2010</ValidFromDate>
            <Division />
            <DivisionPriveIncVat />
            <DivisionDescription />
            <PriceTypeCode>PEXF</PriceTypeCode>
            <PriceTypeDescriptionDe>Ex-Factory Preis</PriceTypeDescriptionDe>
            <PriceTypeDescriptionFr>Prix ex-factory</PriceTypeDescriptionFr>
            <PriceTypeDescriptionIt>Prix ex-factory</PriceTypeDescriptionIt>
            <PriceChangeTypeCode>AUSLANDPV</PriceChangeTypeCode>
            <PriceChangeTypeDescriptionDe>Auslandspreisvergleich</PriceChangeTypeDescriptionDe>
            <PriceChangeTypeDescriptionFr>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionFr>
            <PriceChangeTypeDescriptionIt>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionIt>
          </ExFactoryPrice>
          <PublicPrice>
            <Price>449.35</Price>
            <ValidFromDate>01.03.2010</ValidFromDate>
            <Division />
            <DivisionPriveIncVat />
            <DivisionDescription />
            <PriceTypeCode>PPUB</PriceTypeCode>
            <PriceTypeDescriptionDe>Publikumspreis</PriceTypeDescriptionDe>
            <PriceTypeDescriptionFr>Prix public</PriceTypeDescriptionFr>
            <PriceTypeDescriptionIt>Prix public</PriceTypeDescriptionIt>
            <PriceChangeTypeCode>AUSLANDPV</PriceChangeTypeCode>
            <PriceChangeTypeDescriptionDe>Auslandspreisvergleich</PriceChangeTypeDescriptionDe>
            <PriceChangeTypeDescriptionFr>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionFr>
            <PriceChangeTypeDescriptionIt>Comparaison des prix avec l'étranger</PriceChangeTypeDescriptionIt>
          </PublicPrice>
        </Prices>
        <Partners>
          <Partner>
            <PartnerType>V</PartnerType>
            <Description>Janssen-Cilag AG</Description>
            <Street>Sihlbruggstrasse 111</Street>
            <ZipCode>6341</ZipCode>
            <Place>Baar</Place>
            <Phone>041/767 34 34</Phone>
          </Partner>
        </Partners>
        <Status>
          <IntegrationDate>01.01.2010</IntegrationDate>
          <ValidFromDate>01.01.2010</ValidFromDate>
          <ValidThruDate>31.12.9999</ValidThruDate>
          <StatusTypeCodeSl>0</StatusTypeCodeSl>
          <StatusTypeDescriptionSl>Initialzustand</StatusTypeDescriptionSl>
          <FlagApd>N</FlagApd>
        </Status>
      </Pack>
    </Packs>
    <Substances>
      <Substance>
        <DescriptionLa>Galantamini hydrobromidum</DescriptionLa>
        <Quantity />
        <QuantityUnit />
      </Substance>
    </Substances>
    <Limitations>
      <Limitation>
        <LimitationCode>THERAPIEBEG</LimitationCode>
        <LimitationType>KOM</LimitationType>
        <LimitationNiveau>IP</LimitationNiveau>
        <LimitationValue />
        <DescriptionDe>Zu Therapiebeginn Durchführung z.B. eines Minimentaltests.&lt;br&gt;
Erste Zwischenevaluation nach 3 Monaten, dann alle 6 Monate.&lt;br&gt;
Falls die MMSE1)-Werte unter 10 liegen, ist die Behandlung abzubrechen.&lt;br&gt;
Die Therapie kann nur mit einem Präparat durchgeführt werden.&lt;br&gt;

1) mini mental status examination</DescriptionDe>
        <DescriptionFr>En début de thérapie, application par ex. d'un test minimental.&lt;br&gt;
Première évaluation intermédiaire après trois mois et ensuite tous les six mois.&lt;br&gt;
Si les valeurs MMSE1) sont inférieures à 10, il y a lieu d'interrompre la prise du médicament.&lt;br&gt;
La thérapie ne peut être appliquée qu'avec une préparation.&lt;br&gt;

1) mini mental status examination</DescriptionFr>
        <DescriptionIt>All'inizio della terapia si esegue ad es. un test minimentale.&lt;br&gt;
Prima valutazione intermedia dopo 3 mesi, poi ogni 6 mesi.&lt;br&gt;
Se i valori MMSE1) sono inferiori a 10 bisogna cessare la terapia.&lt;br&gt;
La terapia può essere effettuata soltanto con un preparato.&lt;br&gt;

1) mini mental status examination</DescriptionIt>
        <ValidFromDate>01.01.2007</ValidFromDate>
        <ValidThruDate>31.12.9999</ValidThruDate>
      </Limitation>
    </Limitations>
    <ItCodes>
      <ItCode Code="01.">
        <DescriptionDe>NERVENSYSTEM</DescriptionDe>
        <DescriptionFr>SYSTEME NERVEUX</DescriptionFr>
        <DescriptionIt>SYSTEME NERVEUX</DescriptionIt>
        <Limitations />
      </ItCode>
      <ItCode Code="01.99.">
        <DescriptionDe>Varia</DescriptionDe>
        <DescriptionFr>Varia</DescriptionFr>
        <DescriptionIt>Varia</DescriptionIt>
        <Limitations />
      </ItCode>
    </ItCodes>
    <Status>
      <IntegrationDate>01.07.2005</IntegrationDate>
      <ValidFromDate>01.07.2005</ValidFromDate>
      <ValidThruDate>31.12.9999</ValidThruDate>
      <StatusTypeCodeSl>0</StatusTypeCodeSl>
      <StatusTypeDescriptionSl>Initialzustand</StatusTypeDescriptionSl>
      <FlagApd>N</FlagApd>
    </Status>
  </Preparation>
</Preparations>
      EOS
    end
    def test_download_file
      # Preparing variables
      target_url = @url
      save_dir = File.expand_path 'var', File.dirname(__FILE__)
      file_name = "XMLPublications.zip"

      online_file = @zip
      temp_file = File.join save_dir, 'temp.zip'
      save_file = File.join save_dir, 
               Date.today.strftime("XMLPublications-%Y.%m.%d.zip")
      latest_file = File.join save_dir, 'XMLPublications-latest.zip'
      
      # Preparing mock objects
      flexstub(Tempfile).should_receive(:new).and_return do
        flexmock do |tempfile|
          tempfile.should_receive(:close)
          tempfile.should_receive(:unlink)
          tempfile.should_receive(:path).and_return(temp_file)
        end
      end
 
      fileobj = flexmock do |obj|
        obj.should_receive(:save_as).with(temp_file).and_return do
          FileUtils.cp online_file, temp_file   # instead of downloading
        end
        obj.should_receive(:save_as).with(save_file).and_return do
          FileUtils.cp online_file, save_file   # instead of downloading
        end
      end
      flexstub(Mechanize) do |mechclass|
        mechclass.should_receive(:new).and_return do
          flexmock do |mechobj|
            mechobj.should_receive(:get).and_return(fileobj)
          end
        end
      end

      # Downloading tests
      result = nil
      assert_nothing_raised do
        result = @plugin.download_file(target_url, save_dir, file_name)
      end
      assert_equal save_file, result

      # Not-downloading tests
      assert_nothing_raised do
        result = @plugin.download_file(target_url, save_dir, file_name)
      end
      assert_equal nil, result

      # Check files
      assert File.exist?(save_file), "download to #{save_file} failed."
      assert File.exist?(latest_file), "download to #{latest_file} failed."
    ensure
      FileUtils.rm_r save_dir if File.exists? save_dir
    end
    def test_update_it_codes
      updates = []
      @app.should_receive(:update).times(38).and_return do |ptr, data|
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
      ith = updates.at(0)
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
      pr << "Prescription limitée au maximum à "
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
      ith = updates.at(19)
      assert_equal expected, ith
    end
    def test_update_preparation__unknown_registration__out_of_trade
      updates = []
      flexmock(Package).should_receive(:find_by_pharmacode).
                        times(1).and_return nil
      setup_meddata_server
      @app.should_receive(:registration).and_return nil
      @app.should_receive(:each_package)
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
      @app.should_receive(:each_package)
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
      flexmock(Persistence).should_receive(:find_by_pointer)
      reg.should_receive(:packages).and_return []
      setup_meddata_server
      @app.should_receive(:registration).and_return reg
      @app.should_receive(:each_package)
      @app.should_receive(:delete)
      expected_updates = {}
      ptr = Persistence::Pointer.new [:registration, '39271']
      expected_updates.store ptr, { :generic_type => :original,
                                    :index_therapeuticus => '07.10.10.' }
      ptr += [:sequence, '02']
      expected_updates.store ptr, { :atc_class => 'M01AG01' }
      pac_pointer = ptr += [:package, '028']
      pef = Util::Money.new(2.9)
      pef.origin = "http://bag.e-mediat.net/SL2007.Web.External/File.axd?file=XMLPublications.zip (10.05.2010)"
      ppb = Util::Money.new(7.5)
      ppb.origin = "http://bag.e-mediat.net/SL2007.Web.External/File.axd?file=XMLPublications.zip (10.05.2010)"
      data = { 
        :price_exfactory => pef,
        :sl_generic_type => :original,
        :deductible      => :deductible_g,
        :price_public    => ppb,
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
        :limitation        => nil,
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
        :swissmedic_no5_oddb=> "39271",
        :swissmedic_no5_bag => "12345",
        :swissmedic_no8_bag => "39271028",
        :pharmacode_bag     => "703279",
        :pharmacode_oddb    => "703279",
        :generic_type       => :original,
        :deductible         => :deductible_g,
        :atc_class          => "M01AG01",
      } ]
      assert_equal expected, listener.conflicted_registrations
      assert_equal [], listener.unknown_packages
      expected = []
      assert_equal [], listener.unknown_registrations
    end
    def test_update_preparation__unknown_package__out_of_trade
      reg = setup_registration :iksnr => '39271'
      seq = flexmock 'sequence'
      reg.should_receive(:packages).and_return []
      reg.should_receive(:sequences).and_return({})
      flexmock(Package).should_receive(:find_by_pharmacode).
                        times(1).and_return nil
      setup_meddata_server
      @app.should_receive(:registration).and_return reg
      @app.should_receive(:each_package)
      expected_updates = {}
      ptr = Persistence::Pointer.new [:registration, '39271']
      expected_updates.store ptr, { :generic_type => :original,
                                    :index_therapeuticus => '07.10.10.' }
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
      reg.should_receive(:packages).and_return []
      reg.should_receive(:sequences).and_return({})
      flexmock(Package).should_receive(:find_by_pharmacode).
                        times(1).and_return nil
      setup_meddata_server :ean13 => '7680392710281'
      @app.should_receive(:registration).and_return reg
      @app.should_receive(:each_package)
      expected_updates = {}
      ptr = Persistence::Pointer.new [:registration, '39271']
      expected_updates.store ptr, [{ :generic_type => :original,
                                    :index_therapeuticus => '07.10.10.' }, reg]
      ptr += [:sequence, '01']
      expected_updates.store ptr, [{ :atc_class => 'M01AG01' }, reg]
      seq = flexmock 'sequence'
      seq.should_receive(:compositions).and_return []
      seq.should_receive(:pointer).and_return ptr
      seq.should_receive(:active_agents).and_return([flexmock('active-agent')])
      reg.should_receive(:sequence).and_return(seq)
      expected_updates.store ptr.creator, [{:name_base=>"Ponstan"}, seq]
      ptr += [:package, '028']
      pac = flexmock 'package'
      pac.should_receive(:sl_entry).and_return nil
      data = { 
        :ikscat          => 'B',
        :price_exfactory => Util::Money.new(2.9),
        :sl_generic_type => :original,
        :deductible      => :deductible_g,
        :price_public    => Util::Money.new(7.5),
        :narcotic        => false,
        :pharmacode      => '703279',
      }
      seq.should_receive(:package).and_return pac
      expected_updates.store ptr.creator, [data, pac]
      part = flexmock 'part'
      data = { :composition => nil, :size => '12 Stk' }
      expected_updates.store((ptr + :part).creator, [data, pac])
      sl_entry = flexmock 'sl_entry'
      data = {
        :introduction_date => Date.new(1977, 3, 15),
        :limitation_points => nil,
        :status            => "0",
        :limitation        => nil,
        :bsv_dossier       => "12495",
      }
      expected_updates.store((ptr + :sl_entry).creator, [data, pac])
      @app.should_receive(:update).times(6).and_return do |ptr, data|
        exp, res = expected_updates.delete(ptr)
        assert_equal exp, data
        res
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
        :deductible         => :deductible_g,
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
      reg.should_receive(:packages).and_return []
      package.should_receive(:registration).and_return reg
      flexmock(Package).should_receive(:find_by_pharmacode).
                        times(1).and_return nil
      setup_meddata_server :ean13 => '7680392710281'
      @app.should_receive(:registration).and_return reg
      @app.should_receive(:each_package)
      expected_updates = {}
      ptr = Persistence::Pointer.new [:registration, '39271']
      expected_updates.store ptr, { :generic_type => :original,
                                    :index_therapeuticus => '07.10.10.' }
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
        :deductible         => :deductible_g,
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
      reg.should_receive(:packages).and_return []
      package = setup_package :pharmacode => "703279", :registration => reg, 
                              :steps => %w{39271 02 028}, 
                              :price_public => Util::Money.new(17.65), 
                              :price_exfactory => Util::Money.new(11.22)
      flexmock(Package).should_receive(:find_by_pharmacode).
                        times(1).and_return package
      flexmock(Persistence).should_receive(:find_by_pointer)
      setup_meddata_server
      @app.should_receive(:registration).and_return reg
      @app.should_receive(:each_package)
      @app.should_receive(:delete)
      expected_updates = {}
      ptr = Persistence::Pointer.new [:registration, '39271']
      expected_updates.store ptr, { :generic_type => :original,
                                    :index_therapeuticus => '07.10.10.' }
      ptr += [:sequence, '02']
      expected_updates.store ptr, { :atc_class => 'M01AG01' }
      pac_pointer = ptr += [:package, '028']
      data = { 
        :price_exfactory => Util::Money.new(2.9),
        :sl_generic_type => :original,
        :deductible      => :deductible_g,
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
        :limitation        => nil,
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





=begin
class TestDownloadFile < Test::Unit::TestCase
  include FlexMock::TestCase
  def test_download_file
    target_url = 'http://bag.e-mediat.net/SL2007.Web.External/File.axd?file=XMLPublications.zip'
    save_dir   = './data'
    file_name  = 'XMLPublications.zip'

    online_file = './online/XMLPublications.zip'
    temp_file   = './data/temp'
    save_file = './data/XMLPublications-2010.11.01.zip'
    latest_file = './data/XMLPublications-latest.zip'

    flexstub(Tempfile).should_receive(:new).and_return do
      flexmock do |tempfile|
        tempfile.should_receive(:close)
        tempfile.should_receive(:unlink)
        tempfile.should_receive(:path).and_return('./data/temp')
      end
    end

    fileobj = flexmock do |obj|
      obj.should_receive(:save_as).with(temp_file).and_return do
        FileUtils.cp online_file, temp_file   # instead of downloading
      end
      obj.should_receive(:save_as).with(save_file).and_return do
        FileUtils.cp online_file, save_file   # instead of downloading
      end
    end
    flexstub(Mechanize) do |mechclass|
      mechclass.should_receive(:new).and_return do
        flexmock do |mechobj|
          mechobj.should_receive(:get).and_return(fileobj)
        end
      end
    end

    result = nil
    assert_nothing_raised do
      result = download_file(target_url, save_dir, file_name)
    end
    assert_equal latest_file, result
    assert_nothing_raised do
      result = download_file(target_url, save_dir, file_name)
    end
    assert_equal nil, result
    assert File.exist?(save_file), "download to #{save_file} failed."


  ensure
    FileUtils.rm_r save_dir if File.exists? save_dir
  end
end
=end
