#!/usr/bin/env ruby
# Swissreg::TestSession -- oddb -- 04.05.2006 -- hwyss@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path('../../../src', File.dirname(__FILE__))

require 'test/unit'
require 'session'

module ODDB
	module Swissreg
		class TestSession < Test::Unit::TestCase
			def setup
				@session = Session.new
			end
			def test_extract_result_links
				html = <<-EOS
<html>
				<head>
				<title>Schweizerisches Schutzrechtsregister | Kombi-Suche | Trefferliste</title>
				<style type="text/css"> <!-- a { text-decoration: none; } --> </style>
				<script language="JavaScript">
				<!--
				function showRegister(page) {
				  var register = self.open(page, "register", "width=800,height=500,scrollbars=yes,location=0,toolbar=no,directories=0,status=no,resizable=yes,menubar=no");
				  register.focus();
				}
				function showShopCart(page) {
				  var shopcart = self.open(page, "shopcart", "width=800,height=500,scrollbars=yes,location=0,toolbar=no,directories=0,status=yes,resizable=yes,menubar=no");
				  shopcart.focus();
				}
				//-->
				</script>
				</head>
				<body background="/images/bginstitut2.gif" bgcolor="#ffcc99" alink="#cc3300" link="#ff6600" vlink="#cc3300" text="#333333">
				<div align="left">
				<table border="0" width="100%">
				<tr>
				<td align="left" nowrap><img src="/images/klammer3.gif" width="30" height="57"></td>
				<td align="left" valign="top" height="33" nowrap><img src="/images/ger/navtreff_all.gif" width="300" height="30" align="top" alt="Trefferliste Kombi-Suche"></td>
				<td>&nbsp;</td>
				</tr>
				<tr>
				<td>&nbsp;</td>
				<td align="left" colspan="2" valign="baseline">
				<table border="0" width="90%">
				<tr bgcolor="#FFFFCC">
				<td align="left" nowrap><font face="Arial,Helvetica" color="333333" size="2">Treffer:<b>1</b></font></td>
				</tr
				</table
				<table width="90%" border="0"
				<tr>
				<td valign="bottom"><font size="1" face="Arial, Helvetica, sans-serif">Treffer Nr.</font></td>
				<td valign="bottom"><font size="1" face="Arial, Helvetica, sans-serif">Schutztitel Nr.</font></td>
				<td valign="bottom"><font size="1" face="Arial, Helvetica, sans-serif">Schutztitel Typ</font></td>
				<td valign="bottom"><font size="1" face="Arial, Helvetica, sans-serif">Titel</font></td>
				<td valign="bottom"><font size="1" face="Arial, Helvetica, sans-serif">Warenkorb</font></td>
				</tr>
				<tr>
				<td colspan=9 bgcolor="#333333"><img src="/images/dummys/dummy.gif" width="1" height="3"></td>
				</tr>
				<tr bgcolor="#FFFFCC">
				<td valign="top"><font face="Arial, Helvetica, sans-serif" size="1">1</font></td>
				<td valign="top"><font face="Arial, Helvetica, sans-serif" size="1"><a href="javascript:showRegister('/servlet/ShowServlet?regid=1200107716&sessionid=114673929182148059&lang=ger')" onMouseOver="self.status='Registerauszug anzeigen';return true"onMouseOut= "self.status=' '; return true">C00042544/01</a></font></td>
				<td valign="top"><font face="Arial, Helvetica, sans-serif" size="1">Erg„nzendes Schutzzertifikat</font></td>
				<td valign="top"><font face="Arial, Helvetica, sans-serif" size="1">Loratadin</font></td>
				<td align="center" valign="middle"><a href="javascript:showShopCart('/servlet/ShopCartServlet?regid=1200107716&cmd=add&sessionid=114673929182148059&lang=ger')" onMouseOver="self.status='Dokument bestellen';return true"onMouseOut= "self.status=' '; return true"><img src="/images/buttons/bt_ware_rein.gif" width="35" height="25" alt="Bestellen" border="0"></a></td>
				</tr>
				</table>
				<br><br>
				<table width="90%" border="0">
				<tr>
				<td width="6%">
				<table width="100%" border="0">
				<tr>
				<td bgcolor="#FFFFCC"><font face="Arial, Helvetica, sans-serif" size="2"><b>1</b></font></td>
				</tr>
				</table>
				</td>
				<td width="2%" nowrap>&nbsp;</td>
				<td width="91%" nowrap colspan="3"><a href="/servlet/NewSearchServlet?sessionid=114673929182148059&lang=ger" onMouseOver="self.status='Neue Suchabfrage';return true" onMouseOut= "self.status=' '; return true"><img src="/images/buttons/bt_suche2.gif" width="35" height="30" border="0" alt="Neue Suchabfrage">
				<font face="Arial, Helvetica, sans-serif" size="2" color="black">Neue Suchabfrage</font></a>&nbsp; &nbsp; &nbsp;
				<a href="javascript:showShopCart('/servlet/ShopCartServlet?cmd=show&sessionid=114673929182148059&lang=ger')" onMouseOver="self.status='Warenkorb zeigen';return true" onMouseOut= "self.status=' '; return true"><img src="/images/buttons/bt_ware_leer.gif" width="30" height="25" border="0" alt="Warenkorb zeigen">
				<font face="Arial, Helvetica, sans-serif" size="2" color="black">Warenkorb zeigen</font></a>
				&nbsp; &nbsp; &nbsp;
				<font face="Arial, Helvetica, sans-serif" size="2">
				<a href="javascript:showShopCart('/servlet/ShopCartServlet?cmd=reset&sessionid=114673929182148059&lang=ger')" onMouseOver="self.status='Warenkorb löschen';return true" onMouseOut= "self.status=' '; return true"><img src="/images/buttons/bt_ware_ab.gif" width="30" height="25" border="0" alt="Warenkorb löschen"><font color="black">Warenkorb löschen</font></a></font></td></tr>
				</table>
				</td>
				</tr>
				</table>
				</div>
				</html>
				EOS
				expected = [
					"/servlet/ShowServlet?regid=1200107716"
				]
				assert_equal(expected, @session.extract_result_links(html))
			end
		end
	end
end
