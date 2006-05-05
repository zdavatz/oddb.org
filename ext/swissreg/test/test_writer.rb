#!/usr/bin/env ruby
# Swissreg::TestWriter -- oddb.org -- 03.05.2006 -- hwyss@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path('../../../src', File.dirname(__FILE__))

require 'test/unit'
require 'writer'

module ODDB
	module Swissreg
		class TestWriter < Test::Unit::TestCase
			def setup
				@writer = DetailWriter.new
				@formatter = ODDB::HtmlFormatter.new(@writer)
				@parser = ODDB::HtmlParser.new(@formatter)
			end
			def test_extract_data
				html = <<-EOS
<html>
				<head>
				<title>Schweizerisches Schutzrechtsregister | swissreg-Auszug - ESZ</title>
				<style type="text/css"> <!-- a { text-decoration: none; } --> </style>
				<script language="JavaScript">
				<!--
				function doPrint() {
				  if (navigator.appName.indexOf('Microsoft') >= 0) {
				    var pos1 = navigator.appVersion.indexOf('MSIE ');
				    var pos2 = navigator.appVersion.indexOf('.', pos1);
				    var msieVersion = (pos1 < 0)? 0: parseInt(navigator.appVersion.substring(pos1+5, pos2));
				    if (msieVersion < 5) {
				      alert('Zum Drucken klicken Sie mit der rechten Maustaste in das Fenster und waehlen dann "Drucken".');
				      return;
				    }
				  }
				  self.print();
				  return;
				}
				function showRegister(page) {
				  var register = self.open(page, "register", "width=800,height=500,scrollbars=yes,location=0,toolbar=no,directories=0,status=no,resizable=yes,menubar=no");
				  register.focus();
				}
				function showShopCart(page) {
				  var shopcart = self.open(page, "shopcart", "width=800,height=500,scrollbars=yes,location=0,toolbar=no,directories=0,status=yes,resizable=yes,menubar=no");
				  shopcart.focus();
				}
				function showThumbnails(page) {
				  var thumbnails = self.open(page, "thumbnails", "width=800,height=500,scrollbars=yes,location=0,toolbar=no,directories=0,status=yes,resizable=yes,menubar=no");
				  thumbnails.focus();
				}
				//-->
				</script>
				</head>
				<body background="/images/bginstitut2.gif" bgcolor="#ffcc99" alink="#cc3300" link="#ff6600" vlink="#cc3300" text="#333333">
				<div align="left">
				<table border="0" width="100%">
				<tr>
				<td align="left" nowrap width="30"><img src="/images/klammer3.gif" width="30" height="57"></td>
				<td align="left" valign="top" height="33" nowrap><img src="/images/ger/navshow.gif" width="450" height="30" alt"Schweizerisches Schutzrechtsregister"></td>
				</tr>
				<tr>
				  <td align="left">&nbsp;</td>
				  <td align="left"><font face="Arial, Helvetica, sans-serif" size="2"><b>Disclaimer</b><br> Diese Daten stellen keinen rechtsverbindlichen Registerauszug des Eidgen&ouml;ssischen Instituts f&uuml;r Geistiges Eigentum dar. F&uuml;r die Richtigkeit und Vollst&auml;ndigkeit wird keine Gew&auml;hr &uuml;bernommen.</font></td>
				</tr>
				<tr>
				  <td align="left">&nbsp;</td>
				  <td align="left">&nbsp;</td>
				</tr>
				<tr>
				<td align="left">&nbsp;</td>
				<td align="left"><font face="Arial, Helvetica, sans-serif" size="4"><b>swissreg-Auszug - ESZ<br></b></font></td>
				</tr>
				<tr>
				<td>&nbsp;</td>
				<td>
				<table border="0">
				<tr>
				<td valign="top"><font face="Arial, Helvetica, sans-serif" size="2">Druckdatum:</font></td>
				<td valign="bottom"><font face="Arial, Helvetica, sans-serif" size="2">04.05.2006</font></td>
				</tr>
				<tr>
				<td valign="top"><font face="Arial, Helvetica, sans-serif" size="2">ESZ-Nr.:</font></td>
				<td valign="bottom"><font face="Arial, Helvetica, sans-serif" size="2">C00042544/01</font></td>
				</tr>
				<tr>
				<td valign="top"><font face="Arial, Helvetica, sans-serif" size="2">Erteilungsdatum:</font></td>
				<td valign="bottom"><font face="Arial, Helvetica, sans-serif" size="2">30.04.1996</font></td>
				</tr>
				<tr>
				<td valign="top"><font face="Arial, Helvetica, sans-serif" size="2">Publikationsdatum:</font></td>
				<td valign="bottom"><font face="Arial, Helvetica, sans-serif" size="2">15.02.1996</font></td>
				</tr>
				<tr>
				<td valign="top"><font face="Arial, Helvetica, sans-serif" size="2">Publikations-Nr.:</font></td>
				<td valign="bottom"><font face="Arial, Helvetica, sans-serif" size="2">3</font></td>
				</tr>
				<tr>
				<td valign="top"><font face="Arial, Helvetica, sans-serif" size="2">Gültigkeitsdauer max. bis:</font></td>
				<td valign="bottom"><font face="Arial, Helvetica, sans-serif" size="2">10.06.2006</font></td>
				</tr>
				<tr>
				<td valign="top"><font face="Arial, Helvetica, sans-serif" size="2">Anmeldedatum:</font></td>
				<td valign="bottom"><font face="Arial, Helvetica, sans-serif" size="2">25.10.1995</font></td>
				</tr>
				<tr>
				<td valign="top"><font face="Arial, Helvetica, sans-serif" size="2">Grund-Patent Nr.:</font></td>
				<td valign="bottom"><font face="Arial, Helvetica, sans-serif" size="2"><a href="javascript:showRegister('/servlet/ShowServlet?regid=31042544&sessionid=1146743235709225549&lang=ger')" onMouseOver="self.status='Registerauszug anzeigen'; return true" onMouseOut="self.status=''; return true">00042544</a></font></td>
				</tr>
				<tr>
				<td valign="top"><font face="Arial, Helvetica, sans-serif" size="2">Schutzbeginn des Grund-Patentes:</font></td>
				<td valign="bottom"><font face="Arial, Helvetica, sans-serif" size="2">11.06.1981</font></td>
				</tr>
				</table>
				</td>
				</tr>
				<tr><td>&nbsp;</td><td>&nbsp;</td></tr>
				<tr>
				<td align="left">&nbsp;</td>
				<td align="center"><font face="Arial, Helvetica, sans-serif" size="2"><b><font size="4">Loratadin</font></b></font></td>
				</tr>
				<tr><td>&nbsp;</td><td>&nbsp;</td></tr>
				<tr>
				<td align="left">&nbsp;</td>
				<td align="left"><font face="Arial, Helvetica, sans-serif" size="2"><b>Registrierung</b><br>IKS 48243 18.12.1991</td>
				</tr>
				<tr>
				<td align="left">&nbsp;</td>
				<td align="left"><font face="Arial, Helvetica, sans-serif" size="2"><b>Schutzdauerbeginn</b><br>11.06.2001</td>
				</tr>
				<tr>
				<td align="left">&nbsp;</td>
				<td align="left"><font face="Arial, Helvetica, sans-serif" size="2"><b>Inhaber/in</b><br>Schering Corporation<br>2000 Galloping Hill Road<br>Kenilworth/NJ<br>US-Vereinigte Staaten v. Amerika<br></td>
				</tr>
				<tr>
				<td align="left">&nbsp;</td>
				<td align="left"><font face="Arial, Helvetica, sans-serif" size="2"><b>Vertreter/in</b><br>E. Blum &amp; Co. Patentanwälte<br>Am Vorderberg 11<br>8044 Zürich<br></td>
				</tr>
				<tr>
				<td align="left">&nbsp;</td>
				<td align="left">
				<br><br>
				<table border="0">
				<tr><td><font face="Arial, Helvetica, sans-serif" size="2">
				<a href="javascript:history.back()" OnMouseOver="self.status='Zur&uuml;ck'; return true" OnMouseOut="self.status=''; return true"><img src="/images/buttons/bt_laden.gif" width="30" height="25" alt="Zur&uuml;ck" border="0"><font color="black">Zur&uuml;ck</font></a>
				<img src="/images/dummys/dummy.gif" width="20" height="5">
				<a href="javascript:doPrint()" OnMouseOver="self.status='Drucken'; return true" OnMouseOut="self.status=''; return true"><img src="/images/buttons/bt_druck.gif" width="30" height="25" alt="Drucken" border="0"><font color="black" face="Arial, Helvetica, sans-serif">Drucken</font></a>
				<img src="/images/dummys/dummy.gif" width="20" height="5">
				<a href="javascript:showShopCart('/servlet/ShopCartServlet?regid=1200107716&cmd=add&sessionid=1146743235709225549&lang=ger')" OnMouseOver="self.status='Dokument Bestellen'; return true" OnMouseOut="self.status=''; return true"><img src="/images/buttons/bt_ware_rein.gif" width="35" height="25" alt="Bestellen" border="0"><font color="black">in den Warenkorb</font></a>
				<img src="/images/dummys/dummy.gif" width="20" height="5">
				<a href="javascript:self.close()" OnMouseOver="self.status='Schliessen';return true" OnMouseOut="self.status=' ';return true"><img src="/images/buttons/bt_schliessen.gif" width="30" height="25" alt="Schliessen" border="0"><font color="black" face="Arial, Helvetica, sans-serif">Schliessen</font></a>
				<img src="/images/dummys/dummy.gif" width="20" height="5">
				</font></td></tr>
				</table>
				</td>
				</tr>
				</table>
				</div>
				</body>
				</html>
				EOS
				@parser.feed(html)
				expected = {
					:base_patent				=> "00042544",
					:base_patent_date		=> Date.new(1981, 6, 11),
					:base_patent_srid		=> "31042544",
					:certificate_number	=> "C00042544/01",
					:expiry_date				=> Date.new(2006, 6, 10),
					:iksnr							=> "48243",
					:issue_date					=> Date.new(1996, 4, 30),
					:protection_date		=> Date.new(2001, 6, 11),
					:publication_date		=> Date.new(1996, 2, 15),
					:registration_date	=> Date.new(1995, 10, 25),
				}
				assert_equal(expected, @writer.extract_data)
			end
			def test_extract_data__bag
				html = <<-EOS
<html>
				<head>
				<title>Schweizerisches Schutzrechtsregister | swissreg-Auszug - ESZ</title>
				<style type="text/css"> <!-- a { text-decoration: none; } --> </style>
				<script language="JavaScript">
				<!--
				function doPrint() {
				  if (navigator.appName.indexOf('Microsoft') >= 0) {
				    var pos1 = navigator.appVersion.indexOf('MSIE ');
				    var pos2 = navigator.appVersion.indexOf('.', pos1);
				    var msieVersion = (pos1 < 0)? 0: parseInt(navigator.appVersion.substring(pos1+5, pos2));
				    if (msieVersion < 5) {
				      alert('Zum Drucken klicken Sie mit der rechten Maustaste in das Fenster und waehlen dann "Drucken".');
				      return;
				    }
				  }
				  self.print();
				  return;
				}
				function showRegister(page) {
				  var register = self.open(page, "register", "width=800,height=500,scrollbars=yes,location=0,toolbar=no,directories=0,status=no,resizable=yes,menubar=no");
				  register.focus();
				}
				function showShopCart(page) {
				  var shopcart = self.open(page, "shopcart", "width=800,height=500,scrollbars=yes,location=0,toolbar=no,directories=0,status=yes,resizable=yes,menubar=no");
				  shopcart.focus();
				}
				function showThumbnails(page) {
				  var thumbnails = self.open(page, "thumbnails", "width=800,height=500,scrollbars=yes,location=0,toolbar=no,directories=0,status=yes,resizable=yes,menubar=no");
				  thumbnails.focus();
				}
				//-->
				</script>
				</head>
				<body background="/images/bginstitut2.gif" bgcolor="#ffcc99" alink="#cc3300" link="#ff6600" vlink="#cc3300" text="#333333">
				<div align="left">
				<table border="0" width="100%">
				<tr>
				<td align="left" nowrap width="30"><img src="/images/klammer3.gif" width="30" height="57"></td>
				<td align="left" valign="top" height="33" nowrap><img src="/images/ger/navshow.gif" width="450" height="30" alt"Schweizerisches Schutzrechtsregister"></td>
				</tr>
				<tr>

				  <td align="left">&nbsp;</td>
				  <td align="left"><font face="Arial, Helvetica, sans-serif" size="2"><b>Disclaimer</b><br> Diese Daten stellen keinen rechtsverbindlichen Registerauszug des Eidgen&ouml;ssischen Instituts f&uuml;r Geistiges Eigentum dar. F&uuml;r die Richtigkeit und Vollst&auml;ndigkeit wird keine Gew&auml;hr &uuml;bernommen.</font></td>
				</tr>
				<tr>
				  <td align="left">&nbsp;</td>

				  <td align="left">&nbsp;</td>
				</tr>
				<tr>
				<td align="left">&nbsp;</td>
				<td align="left"><font face="Arial, Helvetica, sans-serif" size="4"><b>swissreg-Auszug - ESZ<br></b></font></td>
				</tr>
				<tr>
				<td>&nbsp;</td>
				<td>
				<table border="0">
				<tr>
				<td valign="top"><font face="Arial, Helvetica, sans-serif" size="2">Druckdatum:</font></td>
				<td valign="bottom"><font face="Arial, Helvetica, sans-serif" size="2">05.05.2006</font></td>

				</tr>
				<tr>
				<td valign="top"><font face="Arial, Helvetica, sans-serif" size="2">ESZ-Nr.:</font></td>
				<td valign="bottom"><font face="Arial, Helvetica, sans-serif" size="2">C00471726/02</font></td>
				</tr>
				<tr>
				<td valign="top"><font face="Arial, Helvetica, sans-serif" size="2">Erteilungsdatum:</font></td>
				<td valign="bottom"><font face="Arial, Helvetica, sans-serif" size="2">31.03.1999</font></td>
				</tr>
				<tr>
				<td valign="top"><font face="Arial, Helvetica, sans-serif" size="2">Publikationsdatum:</font></td>
				<td valign="bottom"><font face="Arial, Helvetica, sans-serif" size="2">15.09.1997</font></td>

				</tr>
				<tr>
				<td valign="top"><font face="Arial, Helvetica, sans-serif" size="2">Publikations-Nr.:</font></td>
				<td valign="bottom"><font face="Arial, Helvetica, sans-serif" size="2">17</font></td>
				</tr>
				<tr>
				<td valign="top"><font face="Arial, Helvetica, sans-serif" size="2">Gültigkeitsdauer max. bis:</font></td>
				<td valign="bottom"><font face="Arial, Helvetica, sans-serif" size="2">25.02.2012</font></td>
				</tr>
				<tr>
				<td valign="top"><font face="Arial, Helvetica, sans-serif" size="2">Anmeldedatum:</font></td>
				<td valign="bottom"><font face="Arial, Helvetica, sans-serif" size="2">18.08.1997</font></td>

				</tr>
				<tr>
				<td valign="top"><font face="Arial, Helvetica, sans-serif" size="2">Grund-Patent Nr.:</font></td>
				<td valign="bottom"><font face="Arial, Helvetica, sans-serif" size="2"><a href="javascript:showRegister('/servlet/ShowServlet?regid=2000471726&sessionid=1146671755347275059&lang=ger')" onMouseOver="self.status='Registerauszug anzeigen'; return true" onMouseOut="self.status=''; return true">00471726</a></font></td>
				</tr>
				<tr>
				<td valign="top"><font face="Arial, Helvetica, sans-serif" size="2">Schutzbeginn des Grund-Patentes:</font></td>
				<td valign="bottom"><font face="Arial, Helvetica, sans-serif" size="2">26.04.1990</font></td>
				</tr>
				</table>
				</td>
				</tr>
				<tr><td>&nbsp;</td><td>&nbsp;</td></tr>

				<tr>
				<td align="left">&nbsp;</td>
				<td align="center"><font face="Arial, Helvetica, sans-serif" size="2"><b><font size="4">Pertactin + Filamentöses Hämoglutin (FHA) + Pertussis-Toxoid + Tetanus-Toxoid + Diphterie-Toxoid + Hib</font></b></font></td>
				</tr>
				<tr><td>&nbsp;</td><td>&nbsp;</td></tr>
				<tr>
				<td align="left">&nbsp;</td>
				<td align="left"><font face="Arial, Helvetica, sans-serif" size="2"><b>Registrierung</b><br>BAG 595 26.02.1997</td>
				</tr>
				<tr>
				<td align="left">&nbsp;</td>
				<td align="left"><font face="Arial, Helvetica, sans-serif" size="2"><b>Schutzdauerbeginn</b><br>26.04.2010</td>

				</tr>
				<tr>
				<td align="left">&nbsp;</td>
				<td align="left"><font face="Arial, Helvetica, sans-serif" size="2"><b>Inhaber/in</b><br>MEDEVA B.V.<br>Churchilllaan 223<br>1078 ED Amsterdam<br>NL-Niederlande<br></td>
				</tr>
				<tr>
				<td align="left">&nbsp;</td>
				<td align="left"><font face="Arial, Helvetica, sans-serif" size="2"><b>Vertreter/in</b><br>E. Blum &amp; Co. Patentanwälte<br>Am Vorderberg 11<br>8044 Zürich<br></td>

				</tr>
				<tr>
				<td align="left">&nbsp;</td>
				<td align="left"> 
				<br><br>
				<table border="0">
				<tr><td><font face="Arial, Helvetica, sans-serif" size="2">
				<a href="javascript:history.back()" OnMouseOver="self.status='Zur&uuml;ck'; return true" OnMouseOut="self.status=''; return true"><img src="/images/buttons/bt_laden.gif" width="30" height="25" alt="Zur&uuml;ck" border="0"><font color="black">Zur&uuml;ck</font></a>
				<img src="/images/dummys/dummy.gif" width="20" height="5">
				<a href="javascript:doPrint()" OnMouseOver="self.status='Drucken'; return true" OnMouseOut="self.status=''; return true"><img src="/images/buttons/bt_druck.gif" width="30" height="25" alt="Drucken" border="0"><font color="black" face="Arial, Helvetica, sans-serif">Drucken</font></a>
				<img src="/images/dummys/dummy.gif" width="20" height="5">
				<a href="javascript:showShopCart('/servlet/ShopCartServlet?regid=1200112698&cmd=add&sessionid=1146671755347275059&lang=ger')" OnMouseOver="self.status='Dokument Bestellen'; return true" OnMouseOut="self.status=''; return true"><img src="/images/buttons/bt_ware_rein.gif" width="35" height="25" alt="Bestellen" border="0"><font color="black">in den Warenkorb</font></a>
				<img src="/images/dummys/dummy.gif" width="20" height="5">

				<a href="javascript:self.close()" OnMouseOver="self.status='Schliessen';return true" OnMouseOut="self.status=' ';return true"><img src="/images/buttons/bt_schliessen.gif" width="30" height="25" alt="Schliessen" border="0"><font color="black" face="Arial, Helvetica, sans-serif">Schliessen</font></a>
				<img src="/images/dummys/dummy.gif" width="20" height="5">
				</font></td></tr>
				</table>
				</td>
				</tr>
				</table>
				</div>
				</body>
				</html>
				EOS
				@parser.feed(html)
				expected = {
					:base_patent				=> "00471726",
					:base_patent_date		=> Date.new(1990, 4, 26),
					:base_patent_srid		=> "2000471726",
					:certificate_number	=> "C00471726/02",
					:expiry_date				=> Date.new(2012, 2, 25),
					:iksnr							=> "00595",
					:issue_date					=> Date.new(1999, 3, 31),
					:protection_date		=> Date.new(2010, 4, 26),
					:publication_date		=> Date.new(1997, 9, 15),
					:registration_date	=> Date.new(1997, 8, 18),
				}
				assert_equal(expected, @writer.extract_data)
			end
			def test_extract_data__fr
				html = <<-EOS
<html>
				<head>
				<title>Schweizerisches Schutzrechtsregister | swissreg-Auszug - ESZ</title>
				<style type="text/css"> <!-- a { text-decoration: none; } --> </style>
				<script language="JavaScript">
				<!--
				function doPrint() {
				  if (navigator.appName.indexOf('Microsoft') >= 0) {
				    var pos1 = navigator.appVersion.indexOf('MSIE ');
				    var pos2 = navigator.appVersion.indexOf('.', pos1);
				    var msieVersion = (pos1 < 0)? 0: parseInt(navigator.appVersion.substring(pos1+5, pos2));
				    if (msieVersion < 5) {
				      alert('Zum Drucken klicken Sie mit der rechten Maustaste in das Fenster und waehlen dann "Drucken".');
				      return;
				    }
				  }
				  self.print();
				  return;
				}
				function showRegister(page) {
				  var register = self.open(page, "register", "width=800,height=500,scrollbars=yes,location=0,toolbar=no,directories=0,status=no,resizable=yes,menubar=no");
				  register.focus();
				}
				function showShopCart(page) {
				  var shopcart = self.open(page, "shopcart", "width=800,height=500,scrollbars=yes,location=0,toolbar=no,directories=0,status=yes,resizable=yes,menubar=no");
				  shopcart.focus();
				}
				function showThumbnails(page) {
				  var thumbnails = self.open(page, "thumbnails", "width=800,height=500,scrollbars=yes,location=0,toolbar=no,directories=0,status=yes,resizable=yes,menubar=no");
				  thumbnails.focus();
				}
				//-->
				</script>
				</head>
				<body background="/images/bginstitut2.gif" bgcolor="#ffcc99" alink="#cc3300" link="#ff6600" vlink="#cc3300" text="#333333">
				<div align="left">
				<table border="0" width="100%">
				<tr>
				<td align="left" nowrap width="30"><img src="/images/klammer3.gif" width="30" height="57"></td>
				<td align="left" valign="top" height="33" nowrap><img src="/images/ger/navshow.gif" width="450" height="30" alt"Schweizerisches Schutzrechtsregister"></td>
				</tr>
				<tr>

				  <td align="left">&nbsp;</td>
				  <td align="left"><font face="Arial, Helvetica, sans-serif" size="2"><b>Disclaimer</b><br> Diese Daten stellen keinen rechtsverbindlichen Registerauszug des Eidgen&ouml;ssischen Instituts f&uuml;r Geistiges Eigentum dar. F&uuml;r die Richtigkeit und Vollst&auml;ndigkeit wird keine Gew&auml;hr &uuml;bernommen.</font></td>
				</tr>
				<tr>
				  <td align="left">&nbsp;</td>

				  <td align="left">&nbsp;</td>
				</tr>
				<tr>
				<td align="left">&nbsp;</td>
				<td align="left"><font face="Arial, Helvetica, sans-serif" size="4"><b>swissreg-Auszug - ESZ<br></b></font></td>
				</tr>
				<tr>
				<td>&nbsp;</td>
				<td>
				<table border="0">
				<tr>
				<td valign="top"><font face="Arial, Helvetica, sans-serif" size="2">Druckdatum:</font></td>
				<td valign="bottom"><font face="Arial, Helvetica, sans-serif" size="2">05.05.2006</font></td>

				</tr>
				<tr>
				<td valign="top"><font face="Arial, Helvetica, sans-serif" size="2">ESZ-Nr.:</font></td>
				<td valign="bottom"><font face="Arial, Helvetica, sans-serif" size="2">C664152/01</font></td>
				</tr>
				<tr>
				<td valign="top"><font face="Arial, Helvetica, sans-serif" size="2">Erteilungsdatum:</font></td>
				<td valign="bottom"><font face="Arial, Helvetica, sans-serif" size="2">29.03.1996</font></td>
				</tr>
				<tr>
				<td valign="top"><font face="Arial, Helvetica, sans-serif" size="2">Publikationsdatum:</font></td>
				<td valign="bottom"><font face="Arial, Helvetica, sans-serif" size="2">13.10.1995</font></td>

				</tr>
				<tr>
				<td valign="top"><font face="Arial, Helvetica, sans-serif" size="2">Publikations-Nr.:</font></td>
				<td valign="bottom"><font face="Arial, Helvetica, sans-serif" size="2">19</font></td>
				</tr>
				<tr>
				<td valign="top"><font face="Arial, Helvetica, sans-serif" size="2">Gültigkeitsdauer max. bis:</font></td>
				<td valign="bottom"><font face="Arial, Helvetica, sans-serif" size="2">13.08.2006</font></td>
				</tr>
				<tr>
				<td valign="top"><font face="Arial, Helvetica, sans-serif" size="2">Anmeldedatum:</font></td>
				<td valign="bottom"><font face="Arial, Helvetica, sans-serif" size="2">08.09.1995</font></td>

				</tr>
				<tr>
				<td valign="top"><font face="Arial, Helvetica, sans-serif" size="2">Grund-Patent Nr.:</font></td>
				<td valign="bottom"><font face="Arial, Helvetica, sans-serif" size="2"><a href="javascript:showRegister('/servlet/ShowServlet?regid=30664152&sessionid=1146671755347275059&lang=ger')" onMouseOver="self.status='Registerauszug anzeigen'; return true" onMouseOut="self.status=''; return true">664152</a></font></td>
				</tr>
				<tr>
				<td valign="top"><font face="Arial, Helvetica, sans-serif" size="2">Schutzbeginn des Grund-Patentes:</font></td>
				<td valign="bottom"><font face="Arial, Helvetica, sans-serif" size="2">25.01.1985</font></td>
				</tr>
				</table>
				</td>
				</tr>
				<tr><td>&nbsp;</td><td>&nbsp;</td></tr>

				<tr>
				<td align="left">&nbsp;</td>
				<td align="center"><font face="Arial, Helvetica, sans-serif" size="2"><b><font size="4">Ondansetron</font></b></font></td>
				</tr>
				<tr><td>&nbsp;</td><td>&nbsp;</td></tr>
				<tr>
				<td align="left">&nbsp;</td>
				<td align="left"><font face="Arial, Helvetica, sans-serif" size="2"><b>Registrierung</b><br>OICM 50709 14.08.1991</td>
				</tr>
				<tr>
				<td align="left">&nbsp;</td>
				<td align="left"><font face="Arial, Helvetica, sans-serif" size="2"><b>Schutzdauerbeginn</b><br>25.01.2005</td>

				</tr>
				<tr>
				<td align="left">&nbsp;</td>
				<td align="left"><font face="Arial, Helvetica, sans-serif" size="2"><b>Inhaber/in</b><br>Glaxo Group Limited<br>Glaxo House
				Berkeley Avenue<br>GB- Greenford (Middx UB6 ONN)<br>GB-Royaume-Uni<br></td>
				</tr>
				<tr>
				<td align="left">&nbsp;</td>
				<td align="left"><font face="Arial, Helvetica, sans-serif" size="2"><b>Vertreter/in</b><br>A. Kerr AG<br>Postfach 444<br>4144 Arlesheim<br></td>

				</tr>
				<tr>
				<td align="left">&nbsp;</td>
				<td align="left"> 
				<br><br>
				<table border="0">
				<tr><td><font face="Arial, Helvetica, sans-serif" size="2">
				<a href="javascript:history.back()" OnMouseOver="self.status='Zur&uuml;ck'; return true" OnMouseOut="self.status=''; return true"><img src="/images/buttons/bt_laden.gif" width="30" height="25" alt="Zur&uuml;ck" border="0"><font color="black">Zur&uuml;ck</font></a>
				<img src="/images/dummys/dummy.gif" width="20" height="5">
				<a href="javascript:doPrint()" OnMouseOver="self.status='Drucken'; return true" OnMouseOut="self.status=''; return true"><img src="/images/buttons/bt_druck.gif" width="30" height="25" alt="Drucken" border="0"><font color="black" face="Arial, Helvetica, sans-serif">Drucken</font></a>
				<img src="/images/dummys/dummy.gif" width="20" height="5">
				<a href="javascript:showShopCart('/servlet/ShopCartServlet?regid=1200110029&cmd=add&sessionid=1146671755347275059&lang=ger')" OnMouseOver="self.status='Dokument Bestellen'; return true" OnMouseOut="self.status=''; return true"><img src="/images/buttons/bt_ware_rein.gif" width="35" height="25" alt="Bestellen" border="0"><font color="black">in den Warenkorb</font></a>
				<img src="/images/dummys/dummy.gif" width="20" height="5">

				<a href="javascript:self.close()" OnMouseOver="self.status='Schliessen';return true" OnMouseOut="self.status=' ';return true"><img src="/images/buttons/bt_schliessen.gif" width="30" height="25" alt="Schliessen" border="0"><font color="black" face="Arial, Helvetica, sans-serif">Schliessen</font></a>
				<img src="/images/dummys/dummy.gif" width="20" height="5">
				</font></td></tr>
				</table>
				</td>
				</tr>
				</table>
				</div>
				</body>
				</html>
				EOS
				@parser.feed(html)
				expected = {
					:base_patent				=> "664152",
					:base_patent_date		=> Date.new(1985, 1, 25),
					:base_patent_srid		=> "30664152",
					:certificate_number	=> "C664152/01",
					:expiry_date				=> Date.new(2006, 8, 13),
					:iksnr							=> "50709",
					:issue_date					=> Date.new(1996, 3, 29),
					:protection_date		=> Date.new(2005, 1, 25),
					:publication_date		=> Date.new(1995, 10, 13),
					:registration_date	=> Date.new(1995, 9, 8),
				}
				assert_equal(expected, @writer.extract_data)
			end
		end
	end
end
