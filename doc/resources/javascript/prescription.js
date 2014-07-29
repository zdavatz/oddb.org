function print_composite_init(comment_id) {
  try {
    for (index = 0; index < 99; ++index) {
      var field_id = 'prescription_comment_' + index;
      var saved_value =  sessionStorage.getItem(field_id, '');
      var x=document.getElementById(field_id);
      var header=document.getElementById('prescription_header_' + index);
      // console.log ('PrescriptionPrintComposite.onload ?? ' + field_id +': set value : ' + x + ' -> ' + saved_value + ' header ' + header);
      if (x != null) {
        if (saved_value != null && saved_value != 'null') {
          x.value = saved_value;
          x.innerHTML = saved_value;
          if (header != null) {
            // console.log ('PrescriptionPrintComposite.onload setting prescription_comment '+comment_id);
            header.value = comment_id;
            header.innerHTML = comment_id;
          }
        } else {
          if (header != null) {
            // console.log ('PrescriptionPrintComposite.onload clearing prescription_comment');
            header.value = '';
            header.innerHTML = '';
          }
        }
      }
    }
    js_restore_prescription_patient_info();
    var field_id = 'prescription_sex';
    var saved_value =  sessionStorage.getItem(field_id, '');
    // console.log ('PrescriptionForm.onload ' + field_id + ':' + document.getElementById(field_id) + ': saved_value ' + saved_value);
    if (saved_value == '1') {
      document.getElementById(field_id).innerHTML = 'w';
    } else {
      document.getElementById(field_id).innerHTML = 'm';
    }
  }
  catch(err) {
    console.log('print_composite_init: catched error: ' + err);
  }
}

function getToday() {
  var currentDate = new Date()
  var day = currentDate.getDate()
  var month = currentDate.getMonth() + 1
  var year = currentDate.getFullYear()
  return year + month +  day;
}

function create_prescription_from_dom() {
  var prescription = new Prescription(guid());
  prescription.doctor_glin              = 'doctor-ean13'
  prescription.doctor_zsr               = 'ZSR?'
  prescription.patient_id               = 'PatID?'
  prescription.date_issued              = getToday()
  prescription.patient_family_name      = document.getElementById('prescription_family_name').value
  prescription.patient_first_name       = document.getElementById('prescription_first_name').value
  prescription.patient_zip_code         = 'PLZ?'
  prescription.patient_birthday         = document.getElementById('prescription_birth_day').value
  prescription.patient_insurance_glin   = 'Vers.Nummer'
    
  for (index = 0; index < 99; ++index) {
    var id = document.getElementById('prescription_comment_' + index);
    if (id == null) { break; }    
    var comment_id = 'prescription_comment_' + index;
    var ean13_id   = 'prescription_ean13_' + index;
    var comment = document.getElementById(comment_id);
    if (comment != null) {
      var prescription_dom =  document.getElementById(ean13_id);
      if (prescription_dom != null) {
        var ean13 = prescription_dom.innerHTML; // value is undefined
        // console.log('create_prescription_from_dom add ' + index + ' ean13 ' + ean13);
        var item = new PrescriptionItem(ean13)
        item.extended_posology = comment.innerHTML;
        prescription.add_item(item);
      }
    }
  }
  return prescription;
}

function add_prescription_qr_code(text_id, element_id) {
//  console.log('add_prescription_qr_code for element '+element_id + ' from text_id ' + text_id);
  try {
    var qrcode = new QRCode(element_id);

    function makeCode () {
      var inhalt =   create_prescription_from_dom().qr_string();
      document.getElementById(text_id).innerHTML = inhalt;
      qrcode.makeCode(inhalt);
    }

    makeCode();
  }
  catch(err) {
    console.log('prescription_form_init: catched error: ' + err);
  }
}

function prescription_form_init(comment_id) {
  try {
    js_restore_prescription_patient_info();
    js_restore_prescription_sex();
    for (index = 0; index < 99; ++index) {
      var field_id = 'prescription_comment_' + index;
      var saved_value =  sessionStorage.getItem(field_id, '');
      var x=document.getElementById(field_id);
      var header=document.getElementById('prescription_header_' + index);
      if (x != null) {
        if (saved_value != null && saved_value != 'null') {
          x.value = saved_value;
          x.innerHTML = saved_value;
          if (header != null) {
            // console.log ('PrescriptionForm.onload setting prescription_comment '+ comment_id);
            header.value = comment_id;
            header.innerHTML = comment_id;
          }
        } else {
          if (header != null) {
            // console.log ('PrescriptionForm.onload clearing prescription_comment');
            header.value = '';
            header.innerHTML = '';
          }
          
        }
        // console.log ('PrescriptionForm.onload ' + field_id +': set value : ' + x + ' -> ' + saved_value);
      } else { break; }
    }
  }
  catch(err) {
    console.log('prescription_form_init: catched error: ' + err);
  }
  document.getElementById('searchbar').focus();
}

function js_clear_session_storage() {
  try {
    for (index = 0; index < 99; ++index) {
      sessionStorage.removeItem("prescription_comment_" + index);
    }
    sessionStorage.removeItem("prescription_sex");
    sessionStorage.removeItem("prescription_first_name");
    sessionStorage.removeItem("prescription_family_name");
    sessionStorage.removeItem("prescription_birth_day");
  }
  catch(err) {
    console.log('js_clear_session_storage: catched error: ' + err);
  }
}
function js_restore_prescription_patient_info() {
    var fields = [ 'prescription_first_name',
     'prescription_family_name',
      'prescription_birth_day',
  ]
  try {
    for (index = 0; index < fields.length; ++index) {
      var field_id = fields[index];
      var saved_value =  sessionStorage.getItem(field_id, '');
      var x=document.getElementById(field_id);
      if (x != null) {
        if (saved_value != null && saved_value != 'null') {
          x.value = saved_value;
          x.innerHTML = saved_value;
        }
        // console.log ('PrescriptionForm.onload ' + field_id +': set value : ' + x + ' -> ' + saved_value);
      }
    }
  }
  catch(err) {
    console.log('js_restore_prescription_patient_info: catched error: ' + err);
  }
}
function js_restore_prescription_sex() {
  try {
    var field_id = 'prescription_sex';
    var saved_value =  sessionStorage.getItem(field_id, '');
    if (saved_value == '1') {
      document.getElementById('prescription_sex_1').checked = true;
      document.getElementById('prescription_sex_2').checked = false;
    } else {
      document.getElementById('prescription_sex_1').checked = false;
      document.getElementById('prescription_sex_2').checked = true;
    }
  }
  catch(err) {
    console.log('js_restore_prescription_sex: catched error: ' + err);
  }
}

function delete_ean_of_index(url, index) {
  try {
    // console.log ('Delete index ' + index + ': going to new url ' + url + ' in prescription');
    for (idx = index; idx < 99; ++idx) {
      var cur_id  = 'prescription_comment_' + idx;
      var next_id = 'prescription_comment_' + (idx+1);
      var next_value =  sessionStorage.getItem(next_id, '');
      if (next_value != '' && next_value != 'null' && next_value != null) {
        sessionStorage.setItem(cur_id, next_value);
        // console.log ('PrescriptionDrugHeader.delete nextvalue ' + cur_id + ': set value : ' + next_value);
      } else {
        sessionStorage. removeItem(cur_id);
      }
    }
    window.top.location.replace(url);
  }
  catch(err) {
    console.log('delete_ean_of_index: catched error: ' + err);
  }
}

// procedure guid taken from http://stackoverflow.com/questions/105034/how-to-create-a-guid-uuid-in-javascript
/**
 * Generates a GUID string.
 * @returns {String} The generated GUID.
 * @example af8a8416-6e18-a307-bd9c-f2c947bbb3aa
 * @author Slavik Meltser (slavik@meltser.info).
 * @link http://slavik.meltser.info/?p=142
 */

function guid() {
    function _p8(s) {
        var p = (Math.random().toString(16)+"000000000").substr(2,8);
        return s ? "-" + p.substr(0,4) + "-" + p.substr(4,4) : p ;
    }
    return _p8() + _p8(true) + _p8(true) + _p8();
}

function PrescriptionItem(ean13) {
  this.ean13 = ean13;
  this.pharmacode = '';
  this.description = '';
  this.quantity = 1;
  this.valid_til = '';
  this.simple_posology = [0, 0, 0, 0];
  this.extended_posology = '';
  this.nr_repetitions = 0;
  this.may_be_substituted = true;
}

function Prescription(guid) {
  this.URL_FORMAT_DESCRIPTION  = 'http://2dmedication.org/';
  this.FORMAT_VERSION          = '1.0';
  this.SW_ORIGIN_ID            = 'ywesee GmBh';
  this.SW_VERSION_ID           = '1.0';
  this.guid = guid;
  this.items = [];
  this.doctor_glin = '';           // aka ean13
  this.doctor_zsr = '';            // ZSR des ausstellenden Arztes
  this.patient_id = '';            // Versichertenkartennummer des Patienten (VEKA)
  this.date_issued = '';           // Datum der Rezeptausstellung
  this.patient_family_name = '';
  this.patient_first_name = '';
  this.patient_zip_code = '';
  this.patient_birthday = '';
  this.patient_insurance_glin
  this.to_s =  'A prescription is '+guid;
  
  this.qr_string = function() { 
    var s = this.URL_FORMAT_DESCRIPTION+'|'+this.FORMAT_VERSION+'|' +
    this.guid + '|' + this.SW_ORIGIN_ID+ '|'+this.SW_VERSION_ID+'|' +
    this.doctor_glin+'|' + this.doctor_zsr+'|' + this.patient_id+'|' + this.date_issued+'|' + 
    this.patient_family_name+'|' + this.patient_first_name+'|'+
    this.patient_zip_code+'|' + this.patient_birthday+'|' + this.patient_insurance_glin+';'
    for (var j = 0; j < this.items.length; j++) {
      var str = '';
      var item = this.items[j];
      if (item.ean13 != undefined) {
        str += item.ean13 + '|' + ( item.pharmacode != undefined ? item.pharmacode : '') + '|' + ( item.description != undefined ?  item.description : '') + '|';
      } else if (item.pharmacode != undefined) {
        str +=  '|' +  item.pharmacode + '|' + item.description + '|';
      } else if (item.description != undefined) {
        str +=  '||' + item.description +'|';
      } else  {
        str +=  'unhandled|';
      }

      str += item.quantity + '|'
      str += item.valid_til  + '|' 
      if (item.simple_posology == undefined) {
          console.log('posology undefined');
        str += '0.00-0.00-0.00-0.00'
      } else {
        formatted =[]
        for (var i = 0; i < item.simple_posology.length; i++) {
          var value = item.simple_posology[i] ? item.simple_posology[i] : 0.00
          str += value.toFixed(2);
          i < item.simple_posology.length-1 ? str += '-' : str += '|'  
        }
      }
      str += item.extended_posology ? item.extended_posology + '|'              : '|'
      str += item.nr_repetitions ? item.nr_repetitions + '|'               : '|'
      str += item.may_be_substituted ? '0|' : '1|'
      s += str;
    }
    s = s.substring(0, s.length -1);
    return s + ';' + this.checksum(s);
  }

  this.checksum = function(string) {
    var sum = 0;
    for (var i = 0; i < string.length; i++) {
      var j = string.charCodeAt(i);
      sum += j;
      // console.log( "checksum i: "+ i + " char <" +string[i] + " -> " + j);
    }
    return sum;
  };    

  this.add_item = function(item2add) {
    this.items.push(item2add);
  };
  
}
