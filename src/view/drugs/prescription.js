#!/usr/bin/env nodejs

module.exports = {
  
// procedure guid taken from http://stackoverflow.com/questions/105034/how-to-create-a-guid-uuid-in-javascript
/**
 * Generates a GUID string.
 * @returns {String} The generated GUID.
 * @example af8a8416-6e18-a307-bd9c-f2c947bbb3aa
 * @author Slavik Meltser (slavik@meltser.info).
 * @link http://slavik.meltser.info/?p=142
 */

guid: function() {
    function _p8(s) {
        var p = (Math.random().toString(16)+"000000000").substr(2,8);
        return s ? "-" + p.substr(0,4) + "-" + p.substr(4,4) : p ;
    }
    return _p8() + _p8(true) + _p8(true) + _p8();
},

PrescriptionItem: function (ean13) {
  this.ean13 = ean13;
  this.pharmacode = '';
  this.description = '';
  this.quantity = 1;
  this.valid_til = '';
  this.simple_posology = [0, 0, 0, 0];
  this.extended_posology = '';
  this.nr_repetitions = 0;
  this.may_be_substituted = true;
},

Prescription: function (guid) {
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
//-";|2014236||1||0.00-0.00-0.00-0.00|||1|||SPEZIALVERBAND|1|20131214|0.00-0.00-0.00-0.00||40|0|7680456740106|||1||1.00-1.00-1.00-0.00|zu Beginn der Mahlzeiten mit mindestens einem halben Glas Wasser einzunehmen||0;27834"
//+";|2014236||1||0.00|0.00|0.00|0.00|||1|||SPEZIALVERBAND|1|20131214|0.00|0.00|0.00|0.00||40|0|7680456740106|||1||1.00|1.00|1.00|0.00|zu Beginn der Mahlzeiten mit mindestens einem halben Glas Wasser einzunehmen||0;28545"

//    QR_TIME_FORMAT          = '%Y%m%d'
//    LOCAL_TIME_FORMAT       = '%d.%m.%Y'
    
}