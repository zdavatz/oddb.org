//  curl https://www.npmjs.org/install.sh | sudo sh
// Very crude unit test for the prescription java test
var tools = require('prescription');

function create_qrcode_example() {
      var item1 = new tools.PrescriptionItem();
      item1.pharmacode = '2014236';
      item1.may_be_substituted = false;

      var item2 = new tools.PrescriptionItem
      item2.description = 'SPEZIALVERBAND'
      item2.valid_til = '20131214' // Time.new(2013, 12, 14)  // '20131214'
      item2.nr_repetitions = 40
      
      var item3 = new tools.PrescriptionItem('7680456740106')
      item3.simple_posology = [1, 1.0, 1, 0]
      item3.extended_posology = 'zu Beginn der Mahlzeiten mit mindestens einem halben Glas Wasser einzunehmen'

      var prescription =  new create_example_prescription
      prescription.add_item(item1)
      prescription.add_item(item2)
      prescription.add_item(item3)
      return prescription
}

function create_example_prescription(){
      var prescription = new tools.Prescription( '4dd33f59-1fbb-4fc9-96f1-488e7175d761');
      prescription.SW_ORIGIN_ID             = 'TriaMed'
      prescription.SW_VERSION_ID            = '3.9.3.0'
      prescription.doctor_glin              = '7601000092786'
      prescription.doctor_zsr               =  'K2345.33'
      prescription.patient_id               = ''
      prescription.date_issued              = '20131104' // Time.new(2013, 11, 04)
      prescription.patient_family_name      = 'Beispiel'
      prescription.patient_first_name       = 'Susanne'
      prescription.patient_zip_code         = '3073'
      prescription.patient_birthday         = '19460801' // Time.new(1946,8,1)
      prescription.patient_insurance_glin   = '7601003000382'
      return prescription   
}
console.log(create_qrcode_example().qr_string());
