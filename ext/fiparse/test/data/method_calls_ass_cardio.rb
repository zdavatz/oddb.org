require 'yaml'
@writer.send_column()
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Fachinformation des Arzneimittel-Kompendium der Schweiz\256")
@writer.send_flowing_data(" ")
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "174"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2627"
      :capheight: "905"
      :avgwidth: "478"
      :flags: "42"
      :descent: "-212"
      :fontname: /Arial-BoldMT
      :fontbbox: 
      - "-628"
      - "-377"
      - "2000"
      - "1010"
    decoder: 
    oid: 53
    src: |-
      53 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -628 -377 2000 1010 ]
      /FontName /Arial-BoldMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 478
      /MaxWidth 2627
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-BoldMT
  :firstchar: "32"
  :name: /F1
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "667"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "611"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
    - "611"
    - "0"
    - "389"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
  :subtype: /TrueType
decoder: 
oid: 7
src: |-
  7 0 obj
  <<
  /Type /Font
  /Name /F1
  /Subtype /TrueType
  /BaseFont /Arial-BoldMT
  /FirstChar 32
  /LastChar 174
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  722 0 722 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 611
  0 0 611 0 278 0 0 0 0 0 611 611 0 389 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 737 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 53 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("ASS Cardio Spirig\256 100")
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "-15"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :avgwidth: "478"
      :flags: "106"
      :descent: "-212"
      :fontname: /Arial-BoldItalicMT
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
    decoder: 
    oid: 54
    src: |-
      54 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 106
      /FontBBox[ -560 -377 1157 1001 ]
      /FontName /Arial-BoldItalicMT
      /ItalicAngle -15
      /StemV 0
      /AvgWidth 478
      /MaxWidth 1716
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-BoldItalicMT
  :firstchar: "32"
  :name: /F2
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "722"
    - "0"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "0"
    - "722"
    - "0"
    - "833"
    - "0"
    - "0"
    - "667"
    - "0"
    - "722"
    - "667"
    - "0"
    - "722"
    - "667"
    - "944"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "611"
    - "556"
    - "611"
    - "556"
    - "333"
    - "611"
    - "611"
    - "278"
    - "0"
    - "556"
    - "278"
    - "889"
    - "611"
    - "611"
    - "611"
    - "0"
    - "389"
    - "556"
    - "333"
    - "611"
    - "556"
    - "778"
    - "0"
    - "0"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
  :subtype: /TrueType
decoder: 
oid: 8
src: |-
  8 0 obj
  <<
  /Type /Font
  /Name /F2
  /Subtype /TrueType
  /BaseFont /Arial-BoldItalicMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722
  722 0 722 667 611 778 722 278 0 722 0 833 0 0 667 0 722 667 0 722 667 944 0 0 611
  0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611 611 0 389 556
  333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 54 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("SPIRIG")
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "-15"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :avgwidth: "478"
      :flags: "106"
      :descent: "-212"
      :fontname: /Arial-BoldItalicMT
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
    decoder: 
    oid: 54
    src: |-
      54 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 106
      /FontBBox[ -560 -377 1157 1001 ]
      /FontName /Arial-BoldItalicMT
      /ItalicAngle -15
      /StemV 0
      /AvgWidth 478
      /MaxWidth 1716
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-BoldItalicMT
  :firstchar: "32"
  :name: /F2
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "722"
    - "0"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "0"
    - "722"
    - "0"
    - "833"
    - "0"
    - "0"
    - "667"
    - "0"
    - "722"
    - "667"
    - "0"
    - "722"
    - "667"
    - "944"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "611"
    - "556"
    - "611"
    - "556"
    - "333"
    - "611"
    - "611"
    - "278"
    - "0"
    - "556"
    - "278"
    - "889"
    - "611"
    - "611"
    - "611"
    - "0"
    - "389"
    - "556"
    - "333"
    - "611"
    - "556"
    - "778"
    - "0"
    - "0"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
  :subtype: /TrueType
decoder: 
oid: 8
src: |-
  8 0 obj
  <<
  /Type /Font
  /Name /F2
  /Subtype /TrueType
  /BaseFont /Arial-BoldItalicMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722
  722 0 722 667 611 778 722 278 0 722 0 833 0 0 667 0 722 667 0 722 667 944 0 0 611
  0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611 611 0 389 556
  333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 54 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("AMZV")
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "-15"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :avgwidth: "478"
      :flags: "106"
      :descent: "-212"
      :fontname: /Arial-BoldItalicMT
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
    decoder: 
    oid: 54
    src: |-
      54 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 106
      /FontBBox[ -560 -377 1157 1001 ]
      /FontName /Arial-BoldItalicMT
      /ItalicAngle -15
      /StemV 0
      /AvgWidth 478
      /MaxWidth 1716
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-BoldItalicMT
  :firstchar: "32"
  :name: /F2
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "722"
    - "0"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "0"
    - "722"
    - "0"
    - "833"
    - "0"
    - "0"
    - "667"
    - "0"
    - "722"
    - "667"
    - "0"
    - "722"
    - "667"
    - "944"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "611"
    - "556"
    - "611"
    - "556"
    - "333"
    - "611"
    - "611"
    - "278"
    - "0"
    - "556"
    - "278"
    - "889"
    - "611"
    - "611"
    - "611"
    - "0"
    - "389"
    - "556"
    - "333"
    - "611"
    - "556"
    - "778"
    - "0"
    - "0"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
  :subtype: /TrueType
decoder: 
oid: 8
src: |-
  8 0 obj
  <<
  /Type /Font
  /Name /F2
  /Subtype /TrueType
  /BaseFont /Arial-BoldItalicMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722
  722 0 722 667 611 778 722 278 0 722 0 833 0 0 667 0 722 667 0 722 667 944 0 0 611
  0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611 611 0 389 556
  333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 54 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Zusammensetzung")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "228"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "-15"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "106"
      :descent: "-212"
      :fontname: /Arial-ItalicMT
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
    decoder: 
    oid: 55
    src: |-
      55 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 106
      /FontBBox[ -517 -325 1082 998 ]
      /FontName /Arial-ItalicMT
      /ItalicAngle -15
      /StemV 0
      /AvgWidth 441
      /MaxWidth 1598
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-ItalicMT
  :firstchar: "32"
  :name: /F3
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "667"
    - "0"
    - "0"
    - "667"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "667"
    - "611"
    - "0"
    - "667"
    - "944"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "0"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 9
src: |-
  9 0 obj
  <<
  /Type /Font
  /Name /F3
  /Subtype /TrueType
  /BaseFont /Arial-ItalicMT
  /FirstChar 32
  /LastChar 228
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0
  667 0 0 667 0 0 722 0 0 0 556 0 722 0 0 0 0 667 611 0 667 944 0 0 0 0 0 0 0 0 0 556
  556 500 556 556 278 556 556 222 0 500 222 833 556 556 556 0 333 500 278 556 0 722
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 55 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Wirkstoff:")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data(" Acetylsalicyls\344ure (ASS).")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "228"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "-15"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "106"
      :descent: "-212"
      :fontname: /Arial-ItalicMT
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
    decoder: 
    oid: 55
    src: |-
      55 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 106
      /FontBBox[ -517 -325 1082 998 ]
      /FontName /Arial-ItalicMT
      /ItalicAngle -15
      /StemV 0
      /AvgWidth 441
      /MaxWidth 1598
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-ItalicMT
  :firstchar: "32"
  :name: /F3
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "667"
    - "0"
    - "0"
    - "667"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "667"
    - "611"
    - "0"
    - "667"
    - "944"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "0"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 9
src: |-
  9 0 obj
  <<
  /Type /Font
  /Name /F3
  /Subtype /TrueType
  /BaseFont /Arial-ItalicMT
  /FirstChar 32
  /LastChar 228
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0
  667 0 0 667 0 0 722 0 0 0 556 0 722 0 0 0 0 667 611 0 667 944 0 0 0 0 0 0 0 0 0 556
  556 500 556 556 278 556 556 222 0 500 222 833 556 556 556 0 333 500 278 556 0 722
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 55 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Hilfsstoffe:")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data(" Color Erythrosin (E 127) Excip. pro compr. obducto.")
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "-15"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :avgwidth: "478"
      :flags: "106"
      :descent: "-212"
      :fontname: /Arial-BoldItalicMT
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
    decoder: 
    oid: 54
    src: |-
      54 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 106
      /FontBBox[ -560 -377 1157 1001 ]
      /FontName /Arial-BoldItalicMT
      /ItalicAngle -15
      /StemV 0
      /AvgWidth 478
      /MaxWidth 1716
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-BoldItalicMT
  :firstchar: "32"
  :name: /F2
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "722"
    - "0"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "0"
    - "722"
    - "0"
    - "833"
    - "0"
    - "0"
    - "667"
    - "0"
    - "722"
    - "667"
    - "0"
    - "722"
    - "667"
    - "944"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "611"
    - "556"
    - "611"
    - "556"
    - "333"
    - "611"
    - "611"
    - "278"
    - "0"
    - "556"
    - "278"
    - "889"
    - "611"
    - "611"
    - "611"
    - "0"
    - "389"
    - "556"
    - "333"
    - "611"
    - "556"
    - "778"
    - "0"
    - "0"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
  :subtype: /TrueType
decoder: 
oid: 8
src: |-
  8 0 obj
  <<
  /Type /Font
  /Name /F2
  /Subtype /TrueType
  /BaseFont /Arial-BoldItalicMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722
  722 0 722 667 611 778 722 278 0 722 0 833 0 0 667 0 722 667 0 722 667 944 0 0 611
  0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611 611 0 389 556
  333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 54 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Galenische Form und Wirkstoffmenge pro Einheit")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("1 Filmtablette ASS Cardio Spirig 100 enth\344lt 100 mg Acetylsalicyls\344ure (ASS) mit magensaft-resistentem \334berzug, Hilfsstoffe und")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("den Farbstoff Erythrosin (E 127).")
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "-15"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :avgwidth: "478"
      :flags: "106"
      :descent: "-212"
      :fontname: /Arial-BoldItalicMT
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
    decoder: 
    oid: 54
    src: |-
      54 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 106
      /FontBBox[ -560 -377 1157 1001 ]
      /FontName /Arial-BoldItalicMT
      /ItalicAngle -15
      /StemV 0
      /AvgWidth 478
      /MaxWidth 1716
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-BoldItalicMT
  :firstchar: "32"
  :name: /F2
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "722"
    - "0"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "0"
    - "722"
    - "0"
    - "833"
    - "0"
    - "0"
    - "667"
    - "0"
    - "722"
    - "667"
    - "0"
    - "722"
    - "667"
    - "944"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "611"
    - "556"
    - "611"
    - "556"
    - "333"
    - "611"
    - "611"
    - "278"
    - "0"
    - "556"
    - "278"
    - "889"
    - "611"
    - "611"
    - "611"
    - "0"
    - "389"
    - "556"
    - "333"
    - "611"
    - "556"
    - "778"
    - "0"
    - "0"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
  :subtype: /TrueType
decoder: 
oid: 8
src: |-
  8 0 obj
  <<
  /Type /Font
  /Name /F2
  /Subtype /TrueType
  /BaseFont /Arial-BoldItalicMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722
  722 0 722 667 611 778 722 278 0 722 0 833 0 0 667 0 722 667 0 722 667 944 0 0 611
  0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611 611 0 389 556
  333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 54 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Indikationen/Anwendungsm\366glichkeiten")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Thrombosepr\344vention (Reokklusionsprophylaxe) nach aortokoronarem Bypass, perkutaner transluminarer Koronarangioplastie")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("(PTCA) und arteriovenoesem Shunt bei Dialysepatienten. Prophylaxe von zerebrovaskul\344ren Insulten, nachdem Vorl\344uferstadien")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("aufgetreten sind (transitorisch-isch\344mische Attacken, TIA).")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Verringerung des Risikos weiterer koronarer Thrombosen nach aufgetretenem Herzinfarkt (Reinfarktprophylaxe).")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Instabile Angina pectoris.")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Prophylaxe von arteriellen Thrombosen nach gef\344sschirurgischen Eingriffen.")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Pr\344vention von Gef\344ssverschl\374ssen bei arterieller Verschlusskrankheit.")
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "-15"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :avgwidth: "478"
      :flags: "106"
      :descent: "-212"
      :fontname: /Arial-BoldItalicMT
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
    decoder: 
    oid: 54
    src: |-
      54 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 106
      /FontBBox[ -560 -377 1157 1001 ]
      /FontName /Arial-BoldItalicMT
      /ItalicAngle -15
      /StemV 0
      /AvgWidth 478
      /MaxWidth 1716
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-BoldItalicMT
  :firstchar: "32"
  :name: /F2
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "722"
    - "0"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "0"
    - "722"
    - "0"
    - "833"
    - "0"
    - "0"
    - "667"
    - "0"
    - "722"
    - "667"
    - "0"
    - "722"
    - "667"
    - "944"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "611"
    - "556"
    - "611"
    - "556"
    - "333"
    - "611"
    - "611"
    - "278"
    - "0"
    - "556"
    - "278"
    - "889"
    - "611"
    - "611"
    - "611"
    - "0"
    - "389"
    - "556"
    - "333"
    - "611"
    - "556"
    - "778"
    - "0"
    - "0"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
  :subtype: /TrueType
decoder: 
oid: 8
src: |-
  8 0 obj
  <<
  /Type /Font
  /Name /F2
  /Subtype /TrueType
  /BaseFont /Arial-BoldItalicMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722
  722 0 722 667 611 778 722 278 0 722 0 833 0 0 667 0 722 667 0 722 667 944 0 0 611
  0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611 611 0 389 556
  333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 54 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Dosierung/Anwendung")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Wenn nicht vom Arzt anders angeordnet, werden folgende Dosierungen empfohlen:")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Thrombosepr\344vention nach Bypass und arterioven\366sem Shunt bei Dialysepatienten: 1\327 100 mg/Tag.")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Nach PTCA: 1\327 100 mg/Tag.")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Prophylaxe von zerebrovaskul\344ren Insulten, nachdem Vorl\344uferstadien (TIA) aufgetreten sind: 3\327 100 mg/Tag.")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Reinfarktprophylaxe und instabile Angina pectoris: 1-3\327 100 mg/Tag.")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Prophylaxe von arteriellen Thrombosen nach gef\344sschirurgischen Eingriffen: 100-300 mg/Tag.")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Pr\344vention von Gef\344ssverschl\374ssen bei arterieller Verschlusskrankheit: 100-300 mg/Tag.")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Es empfiehlt sich, die Filmtabletten mit etwas Fl\374ssigkeit einzunehmen, m\366glichst nach den Mahlzeiten. Etwa \275-1 Glas Fl\374ssigkeit")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("nachtrinken.")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Die Anwendung in der P\344diatrie ist nicht indiziert.")
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "-15"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :avgwidth: "478"
      :flags: "106"
      :descent: "-212"
      :fontname: /Arial-BoldItalicMT
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
    decoder: 
    oid: 54
    src: |-
      54 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 106
      /FontBBox[ -560 -377 1157 1001 ]
      /FontName /Arial-BoldItalicMT
      /ItalicAngle -15
      /StemV 0
      /AvgWidth 478
      /MaxWidth 1716
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-BoldItalicMT
  :firstchar: "32"
  :name: /F2
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "722"
    - "0"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "0"
    - "722"
    - "0"
    - "833"
    - "0"
    - "0"
    - "667"
    - "0"
    - "722"
    - "667"
    - "0"
    - "722"
    - "667"
    - "944"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "611"
    - "556"
    - "611"
    - "556"
    - "333"
    - "611"
    - "611"
    - "278"
    - "0"
    - "556"
    - "278"
    - "889"
    - "611"
    - "611"
    - "611"
    - "0"
    - "389"
    - "556"
    - "333"
    - "611"
    - "556"
    - "778"
    - "0"
    - "0"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
  :subtype: /TrueType
decoder: 
oid: 8
src: |-
  8 0 obj
  <<
  /Type /Font
  /Name /F2
  /Subtype /TrueType
  /BaseFont /Arial-BoldItalicMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722
  722 0 722 667 611 778 722 278 0 722 0 833 0 0 667 0 722 667 0 722 667 944 0 0 611
  0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611 611 0 389 556
  333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 54 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Kontraindikationen")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Ulcus ventriculi und duodeni; h\344morrhagische Diathese; \334berempfindlichkeit gegen Salicylate; einen der Inhaltsstoffe, schwere")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Lebererkrankungen; schwere Niereninsuffizienz; letztes Trimenon der Schwangerschaft.")
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "-15"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :avgwidth: "478"
      :flags: "106"
      :descent: "-212"
      :fontname: /Arial-BoldItalicMT
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
    decoder: 
    oid: 54
    src: |-
      54 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 106
      /FontBBox[ -560 -377 1157 1001 ]
      /FontName /Arial-BoldItalicMT
      /ItalicAngle -15
      /StemV 0
      /AvgWidth 478
      /MaxWidth 1716
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-BoldItalicMT
  :firstchar: "32"
  :name: /F2
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "722"
    - "0"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "0"
    - "722"
    - "0"
    - "833"
    - "0"
    - "0"
    - "667"
    - "0"
    - "722"
    - "667"
    - "0"
    - "722"
    - "667"
    - "944"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "611"
    - "556"
    - "611"
    - "556"
    - "333"
    - "611"
    - "611"
    - "278"
    - "0"
    - "556"
    - "278"
    - "889"
    - "611"
    - "611"
    - "611"
    - "0"
    - "389"
    - "556"
    - "333"
    - "611"
    - "556"
    - "778"
    - "0"
    - "0"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
  :subtype: /TrueType
decoder: 
oid: 8
src: |-
  8 0 obj
  <<
  /Type /Font
  /Name /F2
  /Subtype /TrueType
  /BaseFont /Arial-BoldItalicMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722
  722 0 722 667 611 778 722 278 0 722 0 833 0 0 667 0 722 667 0 722 667 944 0 0 611
  0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611 611 0 389 556
  333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 54 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Warnhinweise und Vorsichtsmassnahmen")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Erh\366hte Vorsicht bei vorgesch\344digter Niere, bei chronischen oder rezidivierenden Magen- oder Duodenalbeschwerden, bei")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Glucose-6-Phosphat-Dehydrogenase-Mangel, bei Asthma, bei \334berempfindlichkeit gegen andere Entz\374ndungshemmer/")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Antirheumatika oder andere allergene Stoffe und bei gleichzeitiger Anwendung von Antikoagulantien (Ausnahme: Low-dose-")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Heparin).")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Bei Kindern unter 12 Jahren, bei denen Verdacht auf Virusgrippe oder Windpocken besteht, sollte die Anwendung von ASS Cardio")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Spirig 100 mit Vorsicht erfolgen (Reye-Syndrom). Ein Kausalzusammenhang dieses Syndroms mit der Einnahme von Salicylat-")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("haltigen Arzneimitteln ist bisher allerdings nicht eindeutig erwiesen.")
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "-15"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :avgwidth: "478"
      :flags: "106"
      :descent: "-212"
      :fontname: /Arial-BoldItalicMT
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
    decoder: 
    oid: 54
    src: |-
      54 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 106
      /FontBBox[ -560 -377 1157 1001 ]
      /FontName /Arial-BoldItalicMT
      /ItalicAngle -15
      /StemV 0
      /AvgWidth 478
      /MaxWidth 1716
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-BoldItalicMT
  :firstchar: "32"
  :name: /F2
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "722"
    - "0"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "0"
    - "722"
    - "0"
    - "833"
    - "0"
    - "0"
    - "667"
    - "0"
    - "722"
    - "667"
    - "0"
    - "722"
    - "667"
    - "944"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "611"
    - "556"
    - "611"
    - "556"
    - "333"
    - "611"
    - "611"
    - "278"
    - "0"
    - "556"
    - "278"
    - "889"
    - "611"
    - "611"
    - "611"
    - "0"
    - "389"
    - "556"
    - "333"
    - "611"
    - "556"
    - "778"
    - "0"
    - "0"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
  :subtype: /TrueType
decoder: 
oid: 8
src: |-
  8 0 obj
  <<
  /Type /Font
  /Name /F2
  /Subtype /TrueType
  /BaseFont /Arial-BoldItalicMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722
  722 0 722 667 611 778 722 278 0 722 0 833 0 0 667 0 722 667 0 722 667 944 0 0 611
  0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611 611 0 389 556
  333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 54 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Interaktionen")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Erh\366ht werden die Wirkung gerinnungshemmender Arzneimittel (z.B. Cumarinderivate und Heparin), das Risiko einer")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("gastrointestinalen Blutung bei gleichzeitiger Behandlung mit Kortikoiden, die Wirkungen und unerw\374nschten Wirkungen aller")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("nichtsteroidalen Antirheumatika, die hypoglyk\344mische Wirkung von Sulfonylharnstoffen und die unerw\374nschten Wirkungen von")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Methotrexat und Phenytoin.")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Vermindert werden die Wirkungen von Spironolacton, Furosemid und harns\344ureausscheidenden Gichtmitteln. Antacida k\366nnen")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("die angestrebten kontinuierlichen Salicylat-Blutspiegel beeintr\344chtigen.")
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "-15"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :avgwidth: "478"
      :flags: "106"
      :descent: "-212"
      :fontname: /Arial-BoldItalicMT
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
    decoder: 
    oid: 54
    src: |-
      54 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 106
      /FontBBox[ -560 -377 1157 1001 ]
      /FontName /Arial-BoldItalicMT
      /ItalicAngle -15
      /StemV 0
      /AvgWidth 478
      /MaxWidth 1716
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-BoldItalicMT
  :firstchar: "32"
  :name: /F2
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "722"
    - "0"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "0"
    - "722"
    - "0"
    - "833"
    - "0"
    - "0"
    - "667"
    - "0"
    - "722"
    - "667"
    - "0"
    - "722"
    - "667"
    - "944"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "611"
    - "556"
    - "611"
    - "556"
    - "333"
    - "611"
    - "611"
    - "278"
    - "0"
    - "556"
    - "278"
    - "889"
    - "611"
    - "611"
    - "611"
    - "0"
    - "389"
    - "556"
    - "333"
    - "611"
    - "556"
    - "778"
    - "0"
    - "0"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
  :subtype: /TrueType
decoder: 
oid: 8
src: |-
  8 0 obj
  <<
  /Type /Font
  /Name /F2
  /Subtype /TrueType
  /BaseFont /Arial-BoldItalicMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722
  722 0 722 667 611 778 722 278 0 722 0 833 0 0 667 0 722 667 0 722 667 944 0 0 611
  0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611 611 0 389 556
  333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 54 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Schwangerschaft/Stillzeit")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Tierstudien haben unerw\374nschte Wirkungen auf den F\366tus gezeigt, aber man verf\374gt \374ber keine kontrollierten Studien bei")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("schwangeren Frauen. Im 1. und 2. Trimenon der Schwangerschaft sollten Acetylsalicyls\344ure oder Salicylate deshalb nur bei")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("strenger Indikationsstellung verabreicht werden. Im 3. Trimenon ist ASS Cardio Spirig 100 wegen h\344morrhagischer Risiken und")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("einer m\366glichen Verz\366gerung des Geburtstermins zu vermeiden.")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("W\344hrend der Stillzeit nur bei zwingender Indikation, wobei bei regelm\344ssiger Anwendung hoher Dosen abgestillt werden muss.")
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "-15"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :avgwidth: "478"
      :flags: "106"
      :descent: "-212"
      :fontname: /Arial-BoldItalicMT
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
    decoder: 
    oid: 54
    src: |-
      54 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 106
      /FontBBox[ -560 -377 1157 1001 ]
      /FontName /Arial-BoldItalicMT
      /ItalicAngle -15
      /StemV 0
      /AvgWidth 478
      /MaxWidth 1716
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-BoldItalicMT
  :firstchar: "32"
  :name: /F2
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "722"
    - "0"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "0"
    - "722"
    - "0"
    - "833"
    - "0"
    - "0"
    - "667"
    - "0"
    - "722"
    - "667"
    - "0"
    - "722"
    - "667"
    - "944"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "611"
    - "556"
    - "611"
    - "556"
    - "333"
    - "611"
    - "611"
    - "278"
    - "0"
    - "556"
    - "278"
    - "889"
    - "611"
    - "611"
    - "611"
    - "0"
    - "389"
    - "556"
    - "333"
    - "611"
    - "556"
    - "778"
    - "0"
    - "0"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
  :subtype: /TrueType
decoder: 
oid: 8
src: |-
  8 0 obj
  <<
  /Type /Font
  /Name /F2
  /Subtype /TrueType
  /BaseFont /Arial-BoldItalicMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722
  722 0 722 667 611 778 722 278 0 722 0 833 0 0 667 0 722 667 0 722 667 944 0 0 611
  0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611 611 0 389 556
  333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 54 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Wirkung auf die Fahrt\374chtigkeit und auf das Bedienen von Maschinen")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Es sind keine Beeintr\344chtigungen zu erwarten.")
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "-15"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :avgwidth: "478"
      :flags: "106"
      :descent: "-212"
      :fontname: /Arial-BoldItalicMT
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
    decoder: 
    oid: 54
    src: |-
      54 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 106
      /FontBBox[ -560 -377 1157 1001 ]
      /FontName /Arial-BoldItalicMT
      /ItalicAngle -15
      /StemV 0
      /AvgWidth 478
      /MaxWidth 1716
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-BoldItalicMT
  :firstchar: "32"
  :name: /F2
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "722"
    - "0"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "0"
    - "722"
    - "0"
    - "833"
    - "0"
    - "0"
    - "667"
    - "0"
    - "722"
    - "667"
    - "0"
    - "722"
    - "667"
    - "944"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "611"
    - "556"
    - "611"
    - "556"
    - "333"
    - "611"
    - "611"
    - "278"
    - "0"
    - "556"
    - "278"
    - "889"
    - "611"
    - "611"
    - "611"
    - "0"
    - "389"
    - "556"
    - "333"
    - "611"
    - "556"
    - "778"
    - "0"
    - "0"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
  :subtype: /TrueType
decoder: 
oid: 8
src: |-
  8 0 obj
  <<
  /Type /Font
  /Name /F2
  /Subtype /TrueType
  /BaseFont /Arial-BoldItalicMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722
  722 0 722 667 611 778 722 278 0 722 0 833 0 0 667 0 722 667 0 722 667 944 0 0 611
  0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611 611 0 389 556
  333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 54 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Unerw\374nschte Wirkungen")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Magenbeschwerden.")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "228"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "-15"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "106"
      :descent: "-212"
      :fontname: /Arial-ItalicMT
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
    decoder: 
    oid: 55
    src: |-
      55 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 106
      /FontBBox[ -517 -325 1082 998 ]
      /FontName /Arial-ItalicMT
      /ItalicAngle -15
      /StemV 0
      /AvgWidth 441
      /MaxWidth 1598
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-ItalicMT
  :firstchar: "32"
  :name: /F3
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "667"
    - "0"
    - "0"
    - "667"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "667"
    - "611"
    - "0"
    - "667"
    - "944"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "0"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 9
src: |-
  9 0 obj
  <<
  /Type /Font
  /Name /F3
  /Subtype /TrueType
  /BaseFont /Arial-ItalicMT
  /FirstChar 32
  /LastChar 228
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0
  667 0 0 667 0 0 722 0 0 0 556 0 722 0 0 0 0 667 611 0 667 944 0 0 0 0 0 0 0 0 0 556
  556 500 556 556 278 556 556 222 0 500 222 833 556 556 556 0 333 500 278 556 0 722
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 55 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Selten:")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data(" Bei h\344ufiger und l\344ngerer Anwendung sind Magenblutungen und \334berempfindlichkeitsreaktionen (Bronchospasmus,")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("\326deme, Urtikaria und andere Hautreaktionen) m\366glich.")
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Seite 1")
@writer.send_line_break()
@writer.send_column()
@writer.send_page()
@writer.send_column()
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Fachinformation des Arzneimittel-Kompendium der Schweiz\256")
@writer.send_flowing_data(" ")
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "228"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "-15"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "106"
      :descent: "-212"
      :fontname: /Arial-ItalicMT
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
    decoder: 
    oid: 55
    src: |-
      55 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 106
      /FontBBox[ -517 -325 1082 998 ]
      /FontName /Arial-ItalicMT
      /ItalicAngle -15
      /StemV 0
      /AvgWidth 441
      /MaxWidth 1598
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-ItalicMT
  :firstchar: "32"
  :name: /F3
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "667"
    - "0"
    - "0"
    - "667"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "667"
    - "611"
    - "0"
    - "667"
    - "944"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "0"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 9
src: |-
  9 0 obj
  <<
  /Type /Font
  /Name /F3
  /Subtype /TrueType
  /BaseFont /Arial-ItalicMT
  /FirstChar 32
  /LastChar 228
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0
  667 0 0 667 0 0 722 0 0 0 556 0 722 0 0 0 0 667 611 0 667 944 0 0 0 0 0 0 0 0 0 556
  556 500 556 556 278 556 556 222 0 500 222 833 556 556 556 0 333 500 278 556 0 722
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 55 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Sehr selten:")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data(" Thrombozytopenie.")
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Schwindel oder Tinnitus k\366nnen, besonders bei Kindern und \344lteren Patienten, Symptome einer \334berdosierung sein. Bei")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("\334berschreiten der empfohlenen Dosierung k\366nnen die Leberenzymwerte (Transaminasen) erh\366ht sein.")
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "-15"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :avgwidth: "478"
      :flags: "106"
      :descent: "-212"
      :fontname: /Arial-BoldItalicMT
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
    decoder: 
    oid: 54
    src: |-
      54 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 106
      /FontBBox[ -560 -377 1157 1001 ]
      /FontName /Arial-BoldItalicMT
      /ItalicAngle -15
      /StemV 0
      /AvgWidth 478
      /MaxWidth 1716
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-BoldItalicMT
  :firstchar: "32"
  :name: /F2
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "722"
    - "0"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "0"
    - "722"
    - "0"
    - "833"
    - "0"
    - "0"
    - "667"
    - "0"
    - "722"
    - "667"
    - "0"
    - "722"
    - "667"
    - "944"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "611"
    - "556"
    - "611"
    - "556"
    - "333"
    - "611"
    - "611"
    - "278"
    - "0"
    - "556"
    - "278"
    - "889"
    - "611"
    - "611"
    - "611"
    - "0"
    - "389"
    - "556"
    - "333"
    - "611"
    - "556"
    - "778"
    - "0"
    - "0"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
  :subtype: /TrueType
decoder: 
oid: 8
src: |-
  8 0 obj
  <<
  /Type /Font
  /Name /F2
  /Subtype /TrueType
  /BaseFont /Arial-BoldItalicMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722
  722 0 722 667 611 778 722 278 0 722 0 833 0 0 667 0 722 667 0 722 667 944 0 0 611
  0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611 611 0 389 556
  333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 54 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("\334berdosierung")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Bei normalen therapeutischen Dosen kommt eine Intoxikation praktisch nicht in Betracht, sie tritt fast nur bei \334berdosierung auf.")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Bei leichten Vergiftungen treten Schwindel und Ohrensausen auf.")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "228"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "-15"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "106"
      :descent: "-212"
      :fontname: /Arial-ItalicMT
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
    decoder: 
    oid: 55
    src: |-
      55 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 106
      /FontBBox[ -517 -325 1082 998 ]
      /FontName /Arial-ItalicMT
      /ItalicAngle -15
      /StemV 0
      /AvgWidth 441
      /MaxWidth 1598
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-ItalicMT
  :firstchar: "32"
  :name: /F3
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "667"
    - "0"
    - "0"
    - "667"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "667"
    - "611"
    - "0"
    - "667"
    - "944"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "0"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 9
src: |-
  9 0 obj
  <<
  /Type /Font
  /Name /F3
  /Subtype /TrueType
  /BaseFont /Arial-ItalicMT
  /FirstChar 32
  /LastChar 228
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0
  667 0 0 667 0 0 722 0 0 0 556 0 722 0 0 0 0 667 611 0 667 944 0 0 0 0 0 0 0 0 0 556
  556 500 556 556 278 556 556 222 0 500 222 833 556 556 556 0 333 500 278 556 0 722
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 55 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Warnung:")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data(" Lokale Reizsymptome, die normalerweise bei einer ASS-\334berdosierung im Vordergrund stehen, wie z.B. Nausea,")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Erbrechen und Magenschmerzen k\366nnen fehlen, da diese ASS-Zubereitung einen magensaftresistenten \334berzug besitzt und nur")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("im D\374nndarm resorbiert wird. Nach hohen Dosen werden beobachtet: Verwirrtheit, Somnolenz, Kollaps, Konvulsionen,")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Atemdepression, Anurie und gelegentlich Blutungen. Die anf\344nglich zentrale Hyperventilation f\374hrt zu verst\344rkter Ausatmung von")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("CO")
@writer.send_flowing_data("2")
@writer.send_flowing_data(" und der Blut-pH steigt an. Durch kompensatorische Bikarbonat-Ausscheidung wird der Urin alkalisch; die Alkali-Reserve wird")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("ersch\366pft, was zu respiratorischer Alkalose f\374hrt. Die klinischen Symptome sind hochgradige Hyperpnoe und Atemnot ohne")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Zyanose mit starkem Schweiss. Bei zunehmender Intoxikation kommt es zur respiratorischen Azidose. Eine Entkopplung der")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("oxidativen Phosphorylierung mit gesteigerter CO")
@writer.send_flowing_data("2")
@writer.send_flowing_data("-Produktion kann zu einer metabolischen Azidose f\374hren.")
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "228"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "-15"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "106"
      :descent: "-212"
      :fontname: /Arial-ItalicMT
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
    decoder: 
    oid: 55
    src: |-
      55 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 106
      /FontBBox[ -517 -325 1082 998 ]
      /FontName /Arial-ItalicMT
      /ItalicAngle -15
      /StemV 0
      /AvgWidth 441
      /MaxWidth 1598
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-ItalicMT
  :firstchar: "32"
  :name: /F3
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "667"
    - "0"
    - "0"
    - "667"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "667"
    - "611"
    - "0"
    - "667"
    - "944"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "0"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 9
src: |-
  9 0 obj
  <<
  /Type /Font
  /Name /F3
  /Subtype /TrueType
  /BaseFont /Arial-ItalicMT
  /FirstChar 32
  /LastChar 228
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0
  667 0 0 667 0 0 722 0 0 0 556 0 722 0 0 0 0 667 611 0 667 944 0 0 0 0 0 0 0 0 0 556
  556 500 556 556 278 556 556 222 0 500 222 833 556 556 556 0 333 500 278 556 0 722
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 55 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Therapie:")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data(" Giftentfernung durch Magensp\374lung, auch in Sp\344tf\344llen, da oft ein Pylorospasmus vorhanden ist. Eine Dosis von 100")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("ml Aktivkohle-Suspension (20 g/100 ml) in 70%iger Sorbitoll\366sung hat sich bei Kindern in milden F\344llen als sehr wirksam erwiesen.")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Der S\344ure-Base-Status und der Elektrolyt-Metabolismus m\374ssen konstant \374berwacht werden. Abh\344ngig von der metabolischen")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Lage erfolgt eine Infusion einer Natriumbikarbonat- oder Natriumcitrat-/-laktat-L\366sung. Dies korrigiert den S\344ure-Base-Status,")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("vergr\366ssert die Alkali-Reserve und f\366rdert die Salicylat-Ausscheidung durch Steigerung des Urin-pH.")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "228"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "-15"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "106"
      :descent: "-212"
      :fontname: /Arial-ItalicMT
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
    decoder: 
    oid: 55
    src: |-
      55 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 106
      /FontBBox[ -517 -325 1082 998 ]
      /FontName /Arial-ItalicMT
      /ItalicAngle -15
      /StemV 0
      /AvgWidth 441
      /MaxWidth 1598
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-ItalicMT
  :firstchar: "32"
  :name: /F3
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "667"
    - "0"
    - "0"
    - "667"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "667"
    - "611"
    - "0"
    - "667"
    - "944"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "0"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 9
src: |-
  9 0 obj
  <<
  /Type /Font
  /Name /F3
  /Subtype /TrueType
  /BaseFont /Arial-ItalicMT
  /FirstChar 32
  /LastChar 228
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0
  667 0 0 667 0 0 722 0 0 0 556 0 722 0 0 0 0 667 611 0 667 944 0 0 0 0 0 0 0 0 0 556
  556 500 556 556 278 556 556 222 0 500 222 833 556 556 556 0 333 500 278 556 0 722
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 55 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Vorsicht:")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data(" Atemstillstand bei zuviel Alkali. Um der Dehydratation entgegenzuwirken und die Ausscheidung von Salicylat zu")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("beschleunigen, sollte Fl\374ssigkeit gegeben werden. Auch die Gabe von Vitamin K und m\366glicherweise Sedativa kommt in Frage.")
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "-15"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :avgwidth: "478"
      :flags: "106"
      :descent: "-212"
      :fontname: /Arial-BoldItalicMT
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
    decoder: 
    oid: 54
    src: |-
      54 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 106
      /FontBBox[ -560 -377 1157 1001 ]
      /FontName /Arial-BoldItalicMT
      /ItalicAngle -15
      /StemV 0
      /AvgWidth 478
      /MaxWidth 1716
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-BoldItalicMT
  :firstchar: "32"
  :name: /F2
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "722"
    - "0"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "0"
    - "722"
    - "0"
    - "833"
    - "0"
    - "0"
    - "667"
    - "0"
    - "722"
    - "667"
    - "0"
    - "722"
    - "667"
    - "944"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "611"
    - "556"
    - "611"
    - "556"
    - "333"
    - "611"
    - "611"
    - "278"
    - "0"
    - "556"
    - "278"
    - "889"
    - "611"
    - "611"
    - "611"
    - "0"
    - "389"
    - "556"
    - "333"
    - "611"
    - "556"
    - "778"
    - "0"
    - "0"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
  :subtype: /TrueType
decoder: 
oid: 8
src: |-
  8 0 obj
  <<
  /Type /Font
  /Name /F2
  /Subtype /TrueType
  /BaseFont /Arial-BoldItalicMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722
  722 0 722 667 611 778 722 278 0 722 0 833 0 0 667 0 722 667 0 722 667 944 0 0 611
  0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611 611 0 389 556
  333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 54 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Eigenschaften/Wirkungen")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("ATC-Code: B01AC06")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Da sogar kleine Dosen von ASS absorbiert werden, werden alle zirkulierenden Blutpl\344ttchen auf dem Weg vom")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Gastrointestinaltrakt zur Leber in den pr\344hepatischen mesenterischen Blutgef\344ssen irreversibel gehemmt. ASS wirkt")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("antithrombotisch durch Hemmung der Thromboxan A")
@writer.send_flowing_data("2")
@writer.send_flowing_data("-Synthese in den Thrombozyten. Die Cyclooxygenase des Endothels")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("(Prostacyclin-Synthese), welche schneller regeneriert wird, ist in der ganzen posthepatischen Zirkulation mit ASS-Konzentrationen")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("von nur sehr geringer Aktivit\344t konfrontiert. Die f\374r die Blutstillung verantwortlichen Pl\344ttchenfunktionen werden nicht wesentlich")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("beeinflusst.")
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "-15"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :avgwidth: "478"
      :flags: "106"
      :descent: "-212"
      :fontname: /Arial-BoldItalicMT
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
    decoder: 
    oid: 54
    src: |-
      54 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 106
      /FontBBox[ -560 -377 1157 1001 ]
      /FontName /Arial-BoldItalicMT
      /ItalicAngle -15
      /StemV 0
      /AvgWidth 478
      /MaxWidth 1716
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-BoldItalicMT
  :firstchar: "32"
  :name: /F2
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "722"
    - "0"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "0"
    - "722"
    - "0"
    - "833"
    - "0"
    - "0"
    - "667"
    - "0"
    - "722"
    - "667"
    - "0"
    - "722"
    - "667"
    - "944"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "611"
    - "556"
    - "611"
    - "556"
    - "333"
    - "611"
    - "611"
    - "278"
    - "0"
    - "556"
    - "278"
    - "889"
    - "611"
    - "611"
    - "611"
    - "0"
    - "389"
    - "556"
    - "333"
    - "611"
    - "556"
    - "778"
    - "0"
    - "0"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
  :subtype: /TrueType
decoder: 
oid: 8
src: |-
  8 0 obj
  <<
  /Type /Font
  /Name /F2
  /Subtype /TrueType
  /BaseFont /Arial-BoldItalicMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722
  722 0 722 667 611 778 722 278 0 722 0 833 0 0 667 0 722 667 0 722 667 944 0 0 611
  0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611 611 0 389 556
  333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 54 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Pharmakokinetik")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Der magensaftresistente \334berzug der Filmtabletten f\374hrt zu einer Freisetzung des Wirkstoffs im D\374nndarm. Im Blut wird die")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("maximale ASS-Konzentration nach ca. 3,5 Stunden und die maximale Salicylat-Konzentration nach 4,7 Stunden erreicht.")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Verglichen mit Aspirin werden die maximalen Plasmaspiegel damit rund 3 Stunden sp\344ter erreicht. Die systemisch verf\374gbare")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("ASS wird bei ASS Cardio Spirig 100 mit einer Halbwertszeit von rund 30 Minuten abgebaut. Die bei der Hydrolyse gebildete")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Salicyls\344ure besitzt eine Plasmahalbwertszeit von rund 2,5 Stunden. Nach Gabe hoher Dosen (>3 g) ist diese aufgrund einer")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("S\344ttigung des konjugierenden Enzymsystems deutlich erh\366ht.")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Die Bioverf\374gbarkeit des Salicylats liegt zwischen 80% und 100%. Die Ausscheidung erfolgt praktisch vollst\344ndig renal als")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Salicyls\344ure (ca. 10%), als Salicylurs\344ure (ca. 75%) und als Konjugate der Salicylurs\344ure (ca. 10%).")
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "228"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "-15"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "106"
      :descent: "-212"
      :fontname: /Arial-ItalicMT
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
    decoder: 
    oid: 55
    src: |-
      55 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 106
      /FontBBox[ -517 -325 1082 998 ]
      /FontName /Arial-ItalicMT
      /ItalicAngle -15
      /StemV 0
      /AvgWidth 441
      /MaxWidth 1598
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-ItalicMT
  :firstchar: "32"
  :name: /F3
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "667"
    - "0"
    - "0"
    - "667"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "667"
    - "611"
    - "0"
    - "667"
    - "944"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "0"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 9
src: |-
  9 0 obj
  <<
  /Type /Font
  /Name /F3
  /Subtype /TrueType
  /BaseFont /Arial-ItalicMT
  /FirstChar 32
  /LastChar 228
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0
  667 0 0 667 0 0 722 0 0 0 556 0 722 0 0 0 0 667 611 0 667 944 0 0 0 0 0 0 0 0 0 556
  556 500 556 556 278 556 556 222 0 500 222 833 556 556 556 0 333 500 278 556 0 722
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 55 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Elimination bei eingeschr\344nkter Leberfunktion")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Da die Metabolisierung der ASS \374berwiegend in der Leber erfolgt, muss mit einem verlangsamten Abbau der ASS zu Salicyls\344ure")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("gerechnet werden (Kumulierung).")
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "228"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "-15"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "106"
      :descent: "-212"
      :fontname: /Arial-ItalicMT
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
    decoder: 
    oid: 55
    src: |-
      55 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 106
      /FontBBox[ -517 -325 1082 998 ]
      /FontName /Arial-ItalicMT
      /ItalicAngle -15
      /StemV 0
      /AvgWidth 441
      /MaxWidth 1598
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-ItalicMT
  :firstchar: "32"
  :name: /F3
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "667"
    - "0"
    - "0"
    - "667"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "667"
    - "611"
    - "0"
    - "667"
    - "944"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "0"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 9
src: |-
  9 0 obj
  <<
  /Type /Font
  /Name /F3
  /Subtype /TrueType
  /BaseFont /Arial-ItalicMT
  /FirstChar 32
  /LastChar 228
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0
  667 0 0 667 0 0 722 0 0 0 556 0 722 0 0 0 0 667 611 0 667 944 0 0 0 0 0 0 0 0 0 556
  556 500 556 556 278 556 556 222 0 500 222 833 556 556 556 0 333 500 278 556 0 722
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 55 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Elimination bei eingeschr\344nkter Nierenfunktion")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Bei Niereninsuffizienz wird die Abbaugeschwindigkeit f\374r die Salicyls\344ure im Blutplasma nicht beeintr\344chtigt; dagegen nimmt der")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Gehalt an inaktiven Salicyls\344ure-Metaboliten, vor allem an konjugierter Salicylurs\344ure aber zu. Salicylate passieren die")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Plazentarschranke, sie erscheinen jedoch nur in geringen Mengen in der Muttermilch.")
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "-15"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :avgwidth: "478"
      :flags: "106"
      :descent: "-212"
      :fontname: /Arial-BoldItalicMT
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
    decoder: 
    oid: 54
    src: |-
      54 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 106
      /FontBBox[ -560 -377 1157 1001 ]
      /FontName /Arial-BoldItalicMT
      /ItalicAngle -15
      /StemV 0
      /AvgWidth 478
      /MaxWidth 1716
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-BoldItalicMT
  :firstchar: "32"
  :name: /F2
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "722"
    - "0"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "0"
    - "722"
    - "0"
    - "833"
    - "0"
    - "0"
    - "667"
    - "0"
    - "722"
    - "667"
    - "0"
    - "722"
    - "667"
    - "944"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "611"
    - "556"
    - "611"
    - "556"
    - "333"
    - "611"
    - "611"
    - "278"
    - "0"
    - "556"
    - "278"
    - "889"
    - "611"
    - "611"
    - "611"
    - "0"
    - "389"
    - "556"
    - "333"
    - "611"
    - "556"
    - "778"
    - "0"
    - "0"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
  :subtype: /TrueType
decoder: 
oid: 8
src: |-
  8 0 obj
  <<
  /Type /Font
  /Name /F2
  /Subtype /TrueType
  /BaseFont /Arial-BoldItalicMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722
  722 0 722 667 611 778 722 278 0 722 0 833 0 0 667 0 722 667 0 722 667 944 0 0 611
  0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611 611 0 389 556
  333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 54 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Pr\344klinische Daten")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("-")
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "-15"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :avgwidth: "478"
      :flags: "106"
      :descent: "-212"
      :fontname: /Arial-BoldItalicMT
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
    decoder: 
    oid: 54
    src: |-
      54 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 106
      /FontBBox[ -560 -377 1157 1001 ]
      /FontName /Arial-BoldItalicMT
      /ItalicAngle -15
      /StemV 0
      /AvgWidth 478
      /MaxWidth 1716
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-BoldItalicMT
  :firstchar: "32"
  :name: /F2
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "722"
    - "0"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "0"
    - "722"
    - "0"
    - "833"
    - "0"
    - "0"
    - "667"
    - "0"
    - "722"
    - "667"
    - "0"
    - "722"
    - "667"
    - "944"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "611"
    - "556"
    - "611"
    - "556"
    - "333"
    - "611"
    - "611"
    - "278"
    - "0"
    - "556"
    - "278"
    - "889"
    - "611"
    - "611"
    - "611"
    - "0"
    - "389"
    - "556"
    - "333"
    - "611"
    - "556"
    - "778"
    - "0"
    - "0"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
  :subtype: /TrueType
decoder: 
oid: 8
src: |-
  8 0 obj
  <<
  /Type /Font
  /Name /F2
  /Subtype /TrueType
  /BaseFont /Arial-BoldItalicMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722
  722 0 722 667 611 778 722 278 0 722 0 833 0 0 667 0 722 667 0 722 667 944 0 0 611
  0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611 611 0 389 556
  333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 54 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Sonstige Hinweise")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "228"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "-15"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "106"
      :descent: "-212"
      :fontname: /Arial-ItalicMT
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
    decoder: 
    oid: 55
    src: |-
      55 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 106
      /FontBBox[ -517 -325 1082 998 ]
      /FontName /Arial-ItalicMT
      /ItalicAngle -15
      /StemV 0
      /AvgWidth 441
      /MaxWidth 1598
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-ItalicMT
  :firstchar: "32"
  :name: /F3
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "667"
    - "0"
    - "0"
    - "667"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "667"
    - "611"
    - "0"
    - "667"
    - "944"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "0"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 9
src: |-
  9 0 obj
  <<
  /Type /Font
  /Name /F3
  /Subtype /TrueType
  /BaseFont /Arial-ItalicMT
  /FirstChar 32
  /LastChar 228
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0
  667 0 0 667 0 0 722 0 0 0 556 0 722 0 0 0 0 667 611 0 667 944 0 0 0 0 0 0 0 0 0 556
  556 500 556 556 278 556 556 222 0 500 222 833 556 556 556 0 333 500 278 556 0 722
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 55 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Haltbarkeit")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Das Medikament darf nur bis zu dem auf dem Beh\344lter mit \253EXP\273 bezeichneten Datum verwendet werden.")
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "228"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "-15"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "106"
      :descent: "-212"
      :fontname: /Arial-ItalicMT
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
    decoder: 
    oid: 55
    src: |-
      55 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 106
      /FontBBox[ -517 -325 1082 998 ]
      /FontName /Arial-ItalicMT
      /ItalicAngle -15
      /StemV 0
      /AvgWidth 441
      /MaxWidth 1598
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-ItalicMT
  :firstchar: "32"
  :name: /F3
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "667"
    - "0"
    - "0"
    - "667"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "667"
    - "611"
    - "0"
    - "667"
    - "944"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "0"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 9
src: |-
  9 0 obj
  <<
  /Type /Font
  /Name /F3
  /Subtype /TrueType
  /BaseFont /Arial-ItalicMT
  /FirstChar 32
  /LastChar 228
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0
  667 0 0 667 0 0 722 0 0 0 556 0 722 0 0 0 0 667 611 0 667 944 0 0 0 0 0 0 0 0 0 556
  556 500 556 556 278 556 556 222 0 500 222 833 556 556 556 0 333 500 278 556 0 722
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 55 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Besondere Lagerungshinweise")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Bei Raumtemperatur (15-25 \260C) vor Licht und Feuchtigkeit gesch\374tzt aufbewahren.")
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "-15"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :avgwidth: "478"
      :flags: "106"
      :descent: "-212"
      :fontname: /Arial-BoldItalicMT
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
    decoder: 
    oid: 54
    src: |-
      54 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 106
      /FontBBox[ -560 -377 1157 1001 ]
      /FontName /Arial-BoldItalicMT
      /ItalicAngle -15
      /StemV 0
      /AvgWidth 478
      /MaxWidth 1716
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-BoldItalicMT
  :firstchar: "32"
  :name: /F2
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "722"
    - "0"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "0"
    - "722"
    - "0"
    - "833"
    - "0"
    - "0"
    - "667"
    - "0"
    - "722"
    - "667"
    - "0"
    - "722"
    - "667"
    - "944"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "611"
    - "556"
    - "611"
    - "556"
    - "333"
    - "611"
    - "611"
    - "278"
    - "0"
    - "556"
    - "278"
    - "889"
    - "611"
    - "611"
    - "611"
    - "0"
    - "389"
    - "556"
    - "333"
    - "611"
    - "556"
    - "778"
    - "0"
    - "0"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
  :subtype: /TrueType
decoder: 
oid: 8
src: |-
  8 0 obj
  <<
  /Type /Font
  /Name /F2
  /Subtype /TrueType
  /BaseFont /Arial-BoldItalicMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722
  722 0 722 667 611 778 722 278 0 722 0 833 0 0 667 0 722 667 0 722 667 944 0 0 611
  0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611 611 0 389 556
  333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 54 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Zulassungsnummer")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("58347 (Swissmedic).")
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "-15"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :avgwidth: "478"
      :flags: "106"
      :descent: "-212"
      :fontname: /Arial-BoldItalicMT
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
    decoder: 
    oid: 54
    src: |-
      54 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 106
      /FontBBox[ -560 -377 1157 1001 ]
      /FontName /Arial-BoldItalicMT
      /ItalicAngle -15
      /StemV 0
      /AvgWidth 478
      /MaxWidth 1716
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-BoldItalicMT
  :firstchar: "32"
  :name: /F2
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "722"
    - "0"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "0"
    - "722"
    - "0"
    - "833"
    - "0"
    - "0"
    - "667"
    - "0"
    - "722"
    - "667"
    - "0"
    - "722"
    - "667"
    - "944"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "611"
    - "556"
    - "611"
    - "556"
    - "333"
    - "611"
    - "611"
    - "278"
    - "0"
    - "556"
    - "278"
    - "889"
    - "611"
    - "611"
    - "611"
    - "0"
    - "389"
    - "556"
    - "333"
    - "611"
    - "556"
    - "778"
    - "0"
    - "0"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
  :subtype: /TrueType
decoder: 
oid: 8
src: |-
  8 0 obj
  <<
  /Type /Font
  /Name /F2
  /Subtype /TrueType
  /BaseFont /Arial-BoldItalicMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722
  722 0 722 667 611 778 722 278 0 722 0 833 0 0 667 0 722 667 0 722 667 944 0 0 611
  0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611 611 0 389 556
  333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 54 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Zulassungsinhaberin")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Spirig Pharma AG, 4622 Egerkingen.")
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "-15"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :avgwidth: "478"
      :flags: "106"
      :descent: "-212"
      :fontname: /Arial-BoldItalicMT
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
    decoder: 
    oid: 54
    src: |-
      54 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 106
      /FontBBox[ -560 -377 1157 1001 ]
      /FontName /Arial-BoldItalicMT
      /ItalicAngle -15
      /StemV 0
      /AvgWidth 478
      /MaxWidth 1716
      >>
      endobj
    target_encoding: latin1
  :basefont: /Arial-BoldItalicMT
  :firstchar: "32"
  :name: /F2
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "722"
    - "0"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "0"
    - "722"
    - "0"
    - "833"
    - "0"
    - "0"
    - "667"
    - "0"
    - "722"
    - "667"
    - "0"
    - "722"
    - "667"
    - "944"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "611"
    - "556"
    - "611"
    - "556"
    - "333"
    - "611"
    - "611"
    - "278"
    - "0"
    - "556"
    - "278"
    - "889"
    - "611"
    - "611"
    - "611"
    - "0"
    - "389"
    - "556"
    - "333"
    - "611"
    - "556"
    - "778"
    - "0"
    - "0"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "611"
  :subtype: /TrueType
decoder: 
oid: 8
src: |-
  8 0 obj
  <<
  /Type /Font
  /Name /F2
  /Subtype /TrueType
  /BaseFont /Arial-BoldItalicMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722
  722 0 722 667 611 778 722 278 0 722 0 833 0 0 667 0 722 667 0 722 667 944 0 0 611
  0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611 611 0 389 556
  333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 54 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Stand der Information")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Februar 1999.")
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Der Text wurde beh\366rdlich genehmigt und vom verantwortlichen Unternehmen zur Publikation durch die Documed AG")
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("freigegeben.\251 Copyright 2007 by Documed AG, Basel. Die unberechtigte Nutzung und Weitergabe ist untersagt. [11.09.2007]")
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :lastchar: "252"
  :type: /Font
  :fontdescriptor: !ruby/object:Rpdf2txt::FontDescriptor 
    attributes: 
      :type: /FontDescriptor
      :italicangle: "0"
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :avgwidth: "441"
      :flags: "42"
      :descent: "-212"
      :fontname: /ArialMT
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
    decoder: 
    oid: 52
    src: |-
      52 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 905
      /CapHeight 905
      /Descent -212
      /Flags 42
      /FontBBox[ -665 -325 2000 1006 ]
      /FontName /ArialMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 441
      /MaxWidth 2664
      >>
      endobj
    target_encoding: latin1
  :basefont: /ArialMT
  :firstchar: "32"
  :name: /F0
  :encoding: /WinAnsiEncoding
  :widths: &id001 
    - "278"
    - "0"
    - "0"
    - "0"
    - "0"
    - "889"
    - "0"
    - "0"
    - "333"
    - "333"
    - "0"
    - "0"
    - "278"
    - "333"
    - "278"
    - "278"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "556"
    - "278"
    - "278"
    - "0"
    - "0"
    - "584"
    - "0"
    - "0"
    - "667"
    - "667"
    - "722"
    - "722"
    - "667"
    - "611"
    - "778"
    - "722"
    - "278"
    - "500"
    - "667"
    - "556"
    - "833"
    - "722"
    - "778"
    - "667"
    - "0"
    - "722"
    - "667"
    - "611"
    - "722"
    - "667"
    - "944"
    - "667"
    - "0"
    - "611"
    - "278"
    - "0"
    - "278"
    - "0"
    - "0"
    - "0"
    - "556"
    - "556"
    - "500"
    - "556"
    - "556"
    - "278"
    - "556"
    - "556"
    - "222"
    - "222"
    - "500"
    - "222"
    - "833"
    - "556"
    - "556"
    - "556"
    - "0"
    - "333"
    - "500"
    - "278"
    - "556"
    - "500"
    - "722"
    - "500"
    - "500"
    - "500"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "737"
    - "0"
    - "556"
    - "0"
    - "0"
    - "737"
    - "0"
    - "400"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "834"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "778"
    - "584"
    - "0"
    - "0"
    - "0"
    - "0"
    - "722"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
    - "0"
    - "0"
    - "0"
    - "0"
    - "0"
    - "556"
  :subtype: /TrueType
decoder: 
oid: 6
src: |-
  6 0 obj
  <<
  /Type /Font
  /Name /F0
  /Subtype /TrueType
  /BaseFont /ArialMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 278 0 0 0 0 889 0 0 333 333 0 0 278 333 278 278 556 556 556 556 556 556
  556 556 556 556 278 278 0 0 584 0 0 667 667 722 722 667 611 778 722 278 500 667 556
  833 722 778 667 0 722 667 611 722 667 944 667 0 611 278 0 278 0 0 0 556 556 500 556
  556 278 556 556 222 222 500 222 833 556 556 556 0 333 500 278 556 500 722 500 500
  500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 0 0 0 0 0 0 0 0 0 556 0 834 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 778 584 0 0 0 0 722 0 0 0 0 0 0 0 556 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 52 0 R
  >>
  endobj
target_encoding: latin1
to_unicode: 
widths: *id001

EOF
@writer.new_font(font)
@writer.send_flowing_data("Seite 2")
@writer.send_line_break()
@writer.send_column()
@writer.send_page()
@writer.send_eof()
