require 'yaml'
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.new_fontsize(-8.0)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Fachinformation des Arzneimittel-Kompendium der Schweiz\256")
@writer.send_flowing_data(" ")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_hr()
@writer.send_line_break()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F4
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "43"
      :avgwidth: "600"
      :fontbbox: 
      - "-21"
      - "-680"
      - "638"
      - "1021"
      :italicangle: "0"
      :fontname: /CourierNewPSMT
      :stemv: "0"
      :ascent: "832"
      :maxwidth: "659"
      :capheight: "832"
      :type: /FontDescriptor
      :descent: "-300"
    decoder: 
    oid: 76
    src: |-
      76 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 832
      /CapHeight 832
      /Descent -300
      /Flags 43
      /FontBBox[ -21 -680 638 1021 ]
      /FontName /CourierNewPSMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 600
      /MaxWidth 659
      >>
      endobj
    target_encoding: latin1
  :basefont: /CourierNewPSMT
  :widths: 
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "0"
  - "600"
  - "0"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  :encoding: /WinAnsiEncoding
  :type: /Font
decoder: 
oid: 10
src: |-
  10 0 obj
  <<
  /Type /Font
  /Name /F4
  /Subtype /TrueType
  /BaseFont /CourierNewPSMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 600 0 0 0 0 600 0 0 600 600 0 0 600 600 600 600 600 600 600 600 600 600
  600 600 600 600 0 0 600 0 600 0 0 600 600 600 600 600 600 600 600 600 600 600 600
  600 600 600 600 0 600 600 600 600 600 0 0 600 600 0 0 0 0 0 0 600 600 600 600 600
  600 600 600 600 600 600 600 600 600 600 600 0 600 600 600 600 600 600 600 600 600
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 600 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 76 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_column()
@writer.send_hr()
@writer.send_line_break()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F1
  :subtype: /TrueType
  :lastchar: "174"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "478"
      :fontbbox: 
      - "-628"
      - "-377"
      - "2000"
      - "1010"
      :italicangle: "0"
      :fontname: /Arial-BoldMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2627"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 73
    src: |-
      73 0 obj
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
  :widths: 
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
  - "556"
  - "611"
  - "0"
  - "333"
  - "0"
  - "0"
  - "278"
  - "0"
  - "0"
  - "278"
  - "0"
  - "611"
  - "611"
  - "611"
  - "0"
  - "389"
  - "0"
  - "0"
  - "0"
  - "556"
  - "0"
  - "556"
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
  - "737"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 278 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 556 611 0
  333 0 0 278 0 0 278 0 611 611 611 0 389 0 0 0 556 0 556 0 500 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  737 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 73 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.new_fontsize(-16.0)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Ciprofloxacin Sandoz\256 i.v.")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F2
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "478"
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
      :italicangle: "-15"
      :fontname: /Arial-BoldItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 74
    src: |-
      74 0 obj
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
  :widths: 
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
  - "278"
  - "278"
  - "556"
  - "556"
  - "556"
  - "0"
  - "0"
  - "0"
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
  - "722"
  - "778"
  - "667"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 278 278 556 556 556 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 722 722 0 722 667 611 778 722 278 0 722 0 833 722 778 667 0 0 667 0 722 667
  944 0 0 611 0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611
  611 0 389 556 333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0
  0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 74 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.new_fontsize(-11.0)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("SANDOZ")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.new_fontsize(-8.0)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("AMZV 9.11.2001")
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Zusammensetzung")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Wirkstoff:")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_flowing_data(" 1 Cyclopropyl-6-fluor-1,4-dihydro-4-oxo-7-(1-piperazinyl)-3-chinolincarbons\344ure (Ciprofloxacinum ut Ciprofloxacini")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("hydrochloridum).")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Hilfsstoffe:")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_flowing_data(" Acidum lacticum, Natrii chloridum, Aqua ad inject.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F2
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "478"
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
      :italicangle: "-15"
      :fontname: /Arial-BoldItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 74
    src: |-
      74 0 obj
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
  :widths: 
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
  - "278"
  - "278"
  - "556"
  - "556"
  - "556"
  - "0"
  - "0"
  - "0"
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
  - "722"
  - "778"
  - "667"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 278 278 556 556 556 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 722 722 0 722 667 611 778 722 278 0 722 0 833 722 778 667 0 0 667 0 722 667
  944 0 0 611 0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611
  611 0 389 556 333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0
  0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 74 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Galenische Form und Wirkstoffmenge pro Einheit")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("L\366sung zur Infusion.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Ciprofloxacinum 200 mg/100 ml ut Ciprofloxacini hydrochloridum.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Ciprofloxacinum 400 mg/200 ml ut Ciprofloxacini hydrochloridum.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F2
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "478"
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
      :italicangle: "-15"
      :fontname: /Arial-BoldItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 74
    src: |-
      74 0 obj
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
  :widths: 
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
  - "278"
  - "278"
  - "556"
  - "556"
  - "556"
  - "0"
  - "0"
  - "0"
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
  - "722"
  - "778"
  - "667"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 278 278 556 556 556 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 722 722 0 722 667 611 778 722 278 0 722 0 833 722 778 667 0 0 667 0 722 667
  944 0 0 611 0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611
  611 0 389 556 333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0
  0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 74 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Indikationen/Anwendungsm\366glichkeiten")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Ciprofloxacin Sandoz i.v. eignet sich zur Behandlung von Infektionen, die durch Ciprofloxacin-empfindliche Erreger hervorgerufen")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("werden:")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Infektionen der Atemwege.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Bei den im ambulanten Bereich h\344ufigen Pneumokokken-Pneumonien ist Ciprofloxacin Sandoz i.v. nicht das Mittel der ersten")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Wahl. Ciprofloxacin Sandoz i.v. kann aber bei Pneumonien, verursacht durch z.B. Klebsiella, Enterobacter, Proteus,")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Pseudomonas, E. coli, Haemophilus, Branhamella, Legionella, Staphylococcus, angezeigt sein.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Bei akuten, durch P. aeruginosa verursachten Infektionssch\374ben bei Kindern und Jugendlichen (5\22617 Jahre) mit Mukoviszidose.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Die Behandlung betr\344gt 10\22614 Tage.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Hals-Nasen-Ohren-Infektionen. Insbesondere wenn sie durch gramnegative Keime einschliesslich Pseudomonas oder durch")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Staphylococcus verursacht sind.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Mund-Zahn-Kiefer-Infektionen.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Infektionen der Nieren und/oder der ableitenden Harnwege.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Infektionen der Geschlechtsorgane, einschliesslich Gonorrh\366 und Adnexitis.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Bei einer begleiteten Infektion durch Chlamydien/Mykoplasmen (nicht- resp. postgonorrhoische Urethritis) ist Ciprofloxacin Sandoz")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("i.v. nicht das Mittel der 1. Wahl (siehe \253Spezielle Dosieranweisung\273). Eine begleitende Lues wird nicht beeinflusst.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Infektionen des Magen-Darm-Traktes.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Infektionen der Gallenwege.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Wund- und Weichteilinfektionen.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Infektionen der Knochen und Gelenke.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Infektionen in Gyn\344kologie und Geburtshilfe.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Sepsis.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Infektionen des Bauchfells (Peritonitis).")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Infektionen der Augen.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Infektionen oder drohende Infektionsgefahr (Prophylaxe) bei Patienten mit geschw\344chter k\366rpereigener Abwehr (z.B. unter")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Behandlung mit Immunsuppressiva bzw. im neutropenischen Zustand).")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Anwendung zur selektiven Darmdekontamination bei immunsuppressiv behandelten Patienten (oral).")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Bei Milzbrand:")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_flowing_data(" Zur Postexpositionsprophylaxe und zur Behandlung des Milzbrandes nach Inhalation des Erregers Bacillus")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("anthracis. Die Wirksamkeit von Ciprofloxacin bei Milzbrand wurde tierexperimentell belegt (siehe Kapitel \253Eigenschaften/")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Wirkungen\273). Bei Kindern, Heranwachsenden, Schwangeren und stillenden Frauen sollte nach Feststellung des Resistenzmusters")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("des beteiligten Bacillus anthracis-Stammes die M\366glichkeit einer Umstellung der Therapie auf (Amino-) penicilline \374berpr\374ft")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("werden.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F2
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "478"
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
      :italicangle: "-15"
      :fontname: /Arial-BoldItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 74
    src: |-
      74 0 obj
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
  :widths: 
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
  - "278"
  - "278"
  - "556"
  - "556"
  - "556"
  - "0"
  - "0"
  - "0"
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
  - "722"
  - "778"
  - "667"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 278 278 556 556 556 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 722 722 0 722 667 611 778 722 278 0 722 0 833 722 778 667 0 0 667 0 722 667
  944 0 0 611 0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611
  611 0 389 556 333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0
  0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 74 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Dosierung/Anwendung")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("\334bliche Dosierung")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F4
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "43"
      :avgwidth: "600"
      :fontbbox: 
      - "-21"
      - "-680"
      - "638"
      - "1021"
      :italicangle: "0"
      :fontname: /CourierNewPSMT
      :stemv: "0"
      :ascent: "832"
      :maxwidth: "659"
      :capheight: "832"
      :type: /FontDescriptor
      :descent: "-300"
    decoder: 
    oid: 76
    src: |-
      76 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 832
      /CapHeight 832
      /Descent -300
      /Flags 43
      /FontBBox[ -21 -680 638 1021 ]
      /FontName /CourierNewPSMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 600
      /MaxWidth 659
      >>
      endobj
    target_encoding: latin1
  :basefont: /CourierNewPSMT
  :widths: 
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "0"
  - "600"
  - "0"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  :encoding: /WinAnsiEncoding
  :type: /Font
decoder: 
oid: 10
src: |-
  10 0 obj
  <<
  /Type /Font
  /Name /F4
  /Subtype /TrueType
  /BaseFont /CourierNewPSMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 600 0 0 0 0 600 0 0 600 600 0 0 600 600 600 600 600 600 600 600 600 600
  600 600 600 600 0 0 600 0 600 0 0 600 600 600 600 600 600 600 600 600 600 600 600
  600 600 600 600 0 600 600 600 600 600 0 0 600 600 0 0 0 0 0 0 600 600 600 600 600
  600 600 600 600 600 600 600 600 600 600 600 0 600 600 600 600 600 600 600 600 600
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 600 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 76 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("                                  Einzel-/Tagesdosen")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("                                  bei Erwachsenen   ")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Einfache Infektionen der          2\327 200 mg         ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("unteren und oberen Harnwege                         ")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Schwere Infektionen der Harnwege  2\327 200 mg bis     ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("                                  2\327 400 mg         ")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Infektionen der Atemwege          2\327 200 mg bis     ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("(je nach Schweregrad und Keim)    2\327 400 mg         ")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Andere Infektionen                2\327 400 mg         ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("(vergleiche Indikationen)                           ")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Bei akuter, unkomplizierter Gonorrh\366 der Frau und des Mannes (Urethritis) und bei einer unkomplizierten Zystitis der Frau reicht")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("die einmalige Infusion von 200 mg.")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Seite 1")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_page()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.new_fontsize(-8.0)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Fachinformation des Arzneimittel-Kompendium der Schweiz\256")
@writer.send_flowing_data(" ")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.new_fontsize(-8.0)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Bei einer notwendigen intraven\366sen Therapie kann die Dosis auf 3\327 400 mg erh\366ht werden, wenn bestimmte ernsthafte")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("lebensbedrohliche oder wiederkehrende Infektionen, speziell bedingt durch Pseudomonas, Staphylococcus und Streptococcus")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("pneumoniae, behandelt werden m\374ssen.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Bei Milzbrand")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Die Behandlung sollte ")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_flowing_data("unverz\374glich")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_flowing_data(" nach einer vermuteten oder best\344tigten Inhalation von Milzbranderregern begonnen werden.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Erwachsene:")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_flowing_data(" 2 mal t\344glich 400 mg (2 mal t\344glich 1 Flasche Ciprofloxacin Sandoz i.v. 400 mg/200 ml bzw. 2 mal t\344glich 2 Flaschen")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("200mg/100 ml).")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Kinder/Jugendliche:")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_flowing_data(" 2 mal t\344glich 10 mg/kg K\366rpergewicht.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Die maximale Einzeldosis bei Kindern sollte 400 mg nicht \374berschreiten.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Behandlungsdauer")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Bei einer intraven\366s begonnenen Postexpositionsprophylaxe oder Behandlung nach Inhalation von Milzbranderregern kann nach")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("klinischem Bild auf orale Weiterbehandlung umgestellt werden; Die Gesamtbehandlungsdauer ist 60 Tage.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Therapeutische Wirksamkeit kann nach Anwendung dieser Dosierungen aufgrund der Empfindlichkeit der Erreger in vitro und der")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("jeweils zu erwartenden Plasmaspiegel angenommen werden (siehe auch Kapitel \253Eigenschaften/Wirkungen\273).")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Eine 60 Min. dauernde Infusion mit 400 mg Ciprofloxacin, alle 8 Std., ist bez\374glich der AUC gleichwertig einer oralen Gabe von")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("750 mg Ciprofloxacin alle 12 Std.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Die intraven\366se Gabe von Ciprofloxacin erfolgt \374ber eine Dauer von 60 Minuten. Die langsame Infusion in eine grosse Vene")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("minimiert das Unbehagen f\374r den Patienten und reduziert das Risiko einer Venenirritation.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Die Infusionsl\366sung kann entweder direkt oder nach vorheriger Zugabe zu anderen Infusionsl\366sungen infundiert werden.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Im Anschluss an die intraven\366se Anwendung ist eine orale Weiterbehandlung m\366glich.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Spezielle Dosierungsanweisungen")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("1. Dosierung bei eingeschr\344nkter Nierenfunktion:")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("1.1 Bei einer Kreatinin-Clearance zwischen 31 und 60 ml/Min./1,73 m\262 oder einem Serum-Kreatinin-Wert zwischen 1,4 und 1,9")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("mg/100 ml (124\226168 \265mol/l) sollte die maximale Tagesdosis f\374r die intraven\366se Gabe 800 mg betragen.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("1.2. Bei einer Kreatinin-Clearance von 30 ml/Min./1,73 m\262 und darunter und einem Serum-Kreatinin-Wert von 2,0 mg/100 ml (177")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("\265mol/l) und dar\374ber sollte die maximale Tagesdosis f\374r die intraven\366se Gabe 400 mg betragen.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("2. Dosierung bei eingeschr\344nkter Nierenfunktion und H\344modialyse:")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Dosierung wie unter 1.2; an den Dialysetagen nach der Dialyse.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("3. Dosierung bei eingeschr\344nkter Leberfunktion:")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Bei eingeschr\344nkter Leberfunktion ist die Ciprofloxacin-Elimination nur wenig ver\344ndert. Bei der \374blichen Dosierung ist keine")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Dosisanpassung erforderlich.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Bei gleichzeitig eingeschr\344nkter Leber- und Nierenfunktion ist die Dosierung dem Grad der Nierenfunktionseinschr\344nkung")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("anzupassen (siehe 1.1 und 1.2).")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("4. Bei Patienten im h\366heren Lebensalter sollten in Abh\344ngigkeit von der eingeschr\344nkten Kreatinin-Clearance die maximalen")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Tagesdosen angepasst werden (siehe unter 1).")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F2
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "478"
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
      :italicangle: "-15"
      :fontname: /Arial-BoldItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 74
    src: |-
      74 0 obj
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
  :widths: 
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
  - "278"
  - "278"
  - "556"
  - "556"
  - "556"
  - "0"
  - "0"
  - "0"
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
  - "722"
  - "778"
  - "667"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 278 278 556 556 556 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 722 722 0 722 667 611 778 722 278 0 722 0 833 722 778 667 0 0 667 0 722 667
  944 0 0 611 0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611
  611 0 389 556 333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0
  0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 74 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Kontraindikationen")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Bei \334berempfindlichkeit gegen Ciprofloxacin oder andere Chemotherapeutika vom Chinolontyp darf Ciprofloxacin Sandoz i.v. nicht")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("angewandt werden.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Ciprofoxacin Sandoz i.v. soll bis zum Vorliegen weiterer Erkenntnisse nicht bei schwangeren und stillenden Frauen angewandt")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("werden.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Kinder und Jugendliche sollen bis zum Abschluss der Wachstumsphase nicht mit Ciprofloxacin Sandoz i.v. behandelt werden, da")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("aufgrund von Ergebnissen aus Tierversuchen Gelenkknorpelsch\344digungen beim noch nicht erwachsenen Organismus nicht")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("ausgeschlossen werden k\366nnen.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Bez\374glich Mukoviszidose und Milzbrand siehe \253Warnhinweise und Vorsichtsmassnahmen\273.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F2
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "478"
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
      :italicangle: "-15"
      :fontname: /Arial-BoldItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 74
    src: |-
      74 0 obj
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
  :widths: 
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
  - "278"
  - "278"
  - "556"
  - "556"
  - "556"
  - "0"
  - "0"
  - "0"
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
  - "722"
  - "778"
  - "667"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 278 278 556 556 556 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 722 722 0 722 667 611 778 722 278 0 722 0 833 722 778 667 0 0 667 0 722 667
  944 0 0 611 0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611
  611 0 389 556 333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0
  0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 74 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Warnhinweise und Vorsichtsmassnahmen")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Wie auch von anderen Gyrasehemmern bekannt, verursacht Ciprofloxacin Sch\344digungen an den gewichtstragenden Gelenken")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("juveniler Tiere. Die Auswertung der Sicherheitsdaten von Patienten im Alter von 18 Jahren mit \374berwiegend zystischer Fibrose")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("(Mukoviszidose) zeigten keine Hinweise auf Gelenk-/Knorpelsch\344digungen.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Die heutigen Erkenntnisse bei Kindern und Jugendlichen st\374tzen die Anwendung von Ciprofloxacin f\374r die Therapie bei akuten,")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("durch P. aeruginosa verursachten Infektionssch\374ben einer zystischen Fibrose und bei Milzbrand (s. Abschnitt \253Indikationen und")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Dosierung\273). Ciprofloxacin wird bei anderen Indikationen nicht empfohlen.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("In seltenen F\344llen kann Ciprofloxacin Photosensitivit\344tsreaktionen verursachen. Diese Patienten sollten es vermeiden sich")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("w\344hrend der Therapie mit Ciprofloxacin l\344ngere Zeit dem Sonnenlicht auszusetzen. Falls dies nicht m\366glich ist, sollte eine")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Sonnenschutzcreme mit gen\374gend hohem Lichtschutzfaktor verwendet, und bedeckende Kleidung f\374r Arme, Beine, evtl. Hut f\374r")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Gesicht getragen werden.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Bei Epileptikern und Patienten mit anderer Vorsch\344digung des Zentralnervensystems (z.B. erniedrigte Krampfschwelle,")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Krampfanf\344lle in der Vorgeschichte, verringerte Hirndurchblutung, Ver\344nderung in der Gehirnstruktur oder Schlaganfall) ist")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Ciprofloxacin Sandoz i.v. nur nach sorgf\344ltiger Nutzen-Risiko-Abw\344gung anzuwenden, da diese Patienten wegen m\366glicher")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("zentralnerv\366ser Nebenwirkungen gef\344hrdet sind.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Die intraven\366se Gabe soll durch eine langsame Infusion \374ber eine Dauer von 60 Minuten erfolgen. Lokale Reaktionen wurden")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("nach der intraven\366sen Gabe von Ciprofloxacin beobachtet. Diese Reaktionen sind h\344ufiger, wenn die Infusionsdauer 30 Minuten")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("betr\344gt oder kleine Venen der Hand ben\374tzt werden.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Eine langfristige und wiederholte Anwendung kann zu Superinfektionen mit resistenten Bakterien oder Sprosspilzen f\374hren.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Auf die M\366glichkeit einer Kreuzresistenz zwischen Ciprofloxacin und anderen Fluorochinolonen ist zu achten.")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Seite 2")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_page()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.new_fontsize(-8.0)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Fachinformation des Arzneimittel-Kompendium der Schweiz\256")
@writer.send_flowing_data(" ")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.new_fontsize(-8.0)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Aufgrund m\366glicher phototoxischer Reaktionen sollten Patienten darauf aufmerksam gemacht werden, \374berm\344ssige")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Sonnenbestrahlung zu vermeiden.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Da Ciprofloxacin vorwiegend \374ber den Urin und weniger auch \374ber das hepatobili\344re System ausgeschieden wird, ist bei Patienten")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("mit eingeschr\344nkter Nierenfunktion Vorsicht geboten.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Es wurde von Kristallurie berichtet (selten), weshalb die Patienten angewiesen werden sollten, genug zu trinken.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F2
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "478"
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
      :italicangle: "-15"
      :fontname: /Arial-BoldItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 74
    src: |-
      74 0 obj
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
  :widths: 
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
  - "278"
  - "278"
  - "556"
  - "556"
  - "556"
  - "0"
  - "0"
  - "0"
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
  - "722"
  - "778"
  - "667"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 278 278 556 556 556 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 722 722 0 722 667 611 778 722 278 0 722 0 833 722 778 667 0 0 667 0 722 667
  944 0 0 611 0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611
  611 0 389 556 333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0
  0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 74 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Interaktionen")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Die gleichzeitige Gabe von Ciprofloxacin und Theophyllin kann zu einem unerw\374nschten Anstieg der Theophyllin-Konzentration")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("im Serum in toxische Bereiche f\374hren. Auf diese Weise k\366nnen Theophyllin-verursachte Nebenwirkungen auftreten. Falls auf eine")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("gleichzeitige Anwendung beider Pr\344parate nicht verzichtet werden kann, soll die Serumkonzentration von Theophyllin kontrolliert")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("und seine Dosierung angemessen reduziert werden.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Aus tierexperimentellen Untersuchungen ist bekannt, dass die Kombination sehr hoher Dosen von Chinolonen (Gyrasehemmern)")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("und einigen nichtsteroidalen Antiphlogistika (wie z.B. Fenbufen, nicht aber Acetylsalicyls\344ure) Kr\344mpfe ausl\366sen kann.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Bei der zeitgleichen Gabe von Ciprofloxacin und Ciclosporin wurde in Einzelf\344llen ein vor\374bergehender Anstieg der")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Serumkreatininkonzentration beobachtet. Aus diesem Grund ist bei diesen Patienten eine engmaschige Kontrolle (2\327 w\366chentlich)")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("des Serumkreatininwertes erforderlich.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Die gleichzeitige Gabe von Ciprofloxacin und Warfarin kann die Wirkung von Warfarin verst\344rken.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("In Einzelf\344llen kann die gleichzeitige Gabe von Ciprofloxacin und Glibenclamid die Wirksamkeit von Glibenclamid verst\344rken")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("(Hypoglyk\344mie).")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Probenecid beeinflusst die renale Sekretion von Ciprofloxacin. Die gleichzeitige Gabe von Probenecid (1000 mg) und Ciprofloxacin")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("(500 mg) erh\366hte die Serumkonzentration von Ciprofloxacin zu etwa 50%, die Eliminationshalbwertzeit blieb unver\344ndert, was bei")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Patienten, welche diese beiden Medikamente gleichzeitig erhalten, beachtet werden sollte.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Metoclopramid beschleunigt die Aufnahme von Ciprofloxacin, wodurch die maximalen Plasmakonzentrationen schneller erreicht")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("werden. Die Bioverf\374gbarkeit von Ciprofloxacin wird nicht beeinflusst.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Bei gleichzeitiger Gabe von Ciprofloxacin und Methotrexat k\366nnen durch kompetive Hemmung der tubul\344ren Sekretion von")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Methotrexat dessen Plasmaspiegel erh\366ht sein. Da dies zu einem gesteigerten Risiko Methotrexat-bedingter Reaktionen f\374hren")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("kann, sollten die Patienten sorgf\344ltig \374berwacht werden.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F2
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "478"
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
      :italicangle: "-15"
      :fontname: /Arial-BoldItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 74
    src: |-
      74 0 obj
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
  :widths: 
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
  - "278"
  - "278"
  - "556"
  - "556"
  - "556"
  - "0"
  - "0"
  - "0"
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
  - "722"
  - "778"
  - "667"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 278 278 556 556 556 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 722 722 0 722 667 611 778 722 278 0 722 0 833 722 778 667 0 0 667 0 722 667
  944 0 0 611 0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611
  611 0 389 556 333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0
  0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 74 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Schwangerschaft/Stillzeit")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Schwangerschafstkategorie C.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Tierversuche haben keine Hinweise auf teratogene Wirkungen (Missbildungen) ergeben, jedoch besteht die M\366glichkeit einer")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Sch\344digung des wachsenden Knorpels.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Ciprofloxacin Sandoz i.v. tritt in das Nabelschnurblut und das Fruchtwasser \374ber. Ciprofloxacin konnte in der Muttermilch in")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("\344hnlichen Konzentrationen wie im m\374tterlichen Serum nachgewiesen werden.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Deshalb soll Ciprofloxacin Sandoz i.v. bis zum Vorliegen weiterer Erkenntnisse nicht bei schwangeren und stillenden Frauen")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("angewendet werden, Ausnahme: Milzbrand (siehe Abschnitt \253Indikationen\273).")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F2
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "478"
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
      :italicangle: "-15"
      :fontname: /Arial-BoldItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 74
    src: |-
      74 0 obj
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
  :widths: 
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
  - "278"
  - "278"
  - "556"
  - "556"
  - "556"
  - "0"
  - "0"
  - "0"
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
  - "722"
  - "778"
  - "667"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 278 278 556 556 556 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 722 722 0 722 667 611 778 722 278 0 722 0 833 722 778 667 0 0 667 0 722 667
  944 0 0 611 0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611
  611 0 389 556 333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0
  0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 74 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Wirkung auf die Fahrt\374chtigkeit und auf das Bedienen von Maschinen")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Durch individuell auftretende unterschiedliche Reaktionen kann die F\344higkeit zur aktiven Teilnahme am Strassenverkehr oder zum")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Bedienen von Maschinen beeintr\344chtigt werden. Dies gilt in verst\344rktem Masse im Zusammenwirken mit Alkohol.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F2
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "478"
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
      :italicangle: "-15"
      :fontname: /Arial-BoldItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 74
    src: |-
      74 0 obj
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
  :widths: 
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
  - "278"
  - "278"
  - "556"
  - "556"
  - "556"
  - "0"
  - "0"
  - "0"
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
  - "722"
  - "778"
  - "667"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 278 278 556 556 556 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 722 722 0 722 667 611 778 722 278 0 722 0 833 722 778 667 0 0 667 0 722 667
  944 0 0 611 0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611
  611 0 389 556 333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0
  0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 74 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Unerw\374nschte Wirkungen")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Es wurden folgende unerw\374nschte Arzneimittelwirkungen beobachtet:")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Magen-Darm-Beschwerden")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Bei 2\22610% der Patienten traten \334belkeit, Durchfall, Erbrechen, Verdauungsst\366rungen, Bauchschmerzen, Bl\344hungen,")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Appetitlosigkeit auf.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Beim Auftreten von schweren und anhaltenden Durchf\344llen w\344hrend oder nach der Therapie kann sich dahinter eine")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("ernstzunehmende Darmerkrankung (pseudomembran\366se Kolitis) verbergen, die sofort behandelt werden muss. In solchen F\344llen")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("ist Ciprofloxacin Sandoz i.v. abzusetzen und eine geeignete Diagnostik und Therapie einzuleiten (z.B. Vancomycin oral, 4\327 250")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("mg t\344glich). Peristaltikhemmende Pr\344parate sind kontraindiziert.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Sehr selten:")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_flowing_data(" Pankreatitis")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("St\366rungen des zentralen Nervensystems")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Gelegentlich:")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_flowing_data(" Schwindel, Kopfschmerz, M\374digkeit, Schlaflosigkeit, Erregtheit, Zittern.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Sehr selten:")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_flowing_data(" periphere Empfindungsst\366rungen, Zuckungen, Hypo- und Hyperaestesie, Muskelverspannung, Bein-, R\374cken-,")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Brustschmerzen, Schwitzen, Gangunsicherheit, Krampfanf\344lle, Erh\366hung des Sch\344delinnendruckes, Angstzust\344nde, Albtr\344ume,")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Verst\366rtheit, Depressionen, Halluzinationen, in Einzelf\344llen psychotische Reaktionen, Geschmacks- und Geruchsst\366rungen,")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Sehst\366rungen (z.B. Diplopie, Farbsehen). Diese Reaktionen traten teilweise schon nach Verabreichung auf. In diesen F\344llen ist")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Ciprofloxacin Sandoz i.v. sofort abzusetzen.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("\334berempfindlichkeitsreaktionen")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Gelegentlich:")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_flowing_data(" Hautreaktionen wie z.B. Hautausschl\344ge.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Sehr selten:")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_flowing_data(" Juckreiz, Arzneimittelfieber, Urticaria, Hyperpigmentation, anaphylaktische/anaphylaktoide Reaktionen (z.B.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Gesichts-, Gef\344ss- und Kehlkopf\366dem; Atemnot bis hin zum bedrohlichen Schock), teilweise schon nach Verabreichung. In diesen")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("F\344llen ist Ciprofloxacin Sandoz i.v. sofort abzusetzen, eine \344rztliche Behandlung (z.B. Schocktherapie) ist erforderlich.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Punktf\366rmige Hautblutungen (Petechien), Blasenbildungen mit Einblutungen (h\344morrhagische Bullae) und kleine Kn\366tchen")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("(Papeln) mit Krustenbildung als Ausdruck einer Gef\344ssbeteiligung (Vaskulitis), Erythema nodosum, Erythema exsudativum")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("multiforme (minor), Stevens-Johnson-Syndrom, Lyell-Syndrom, interstitielle Nephritis, Hepatitis, Leberzellnekrose bis hin zum")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("lebensbedrohlichen Leberausfall.")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Seite 3")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_page()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.new_fontsize(-8.0)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Fachinformation des Arzneimittel-Kompendium der Schweiz\256")
@writer.send_flowing_data(" ")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_hr()
@writer.send_line_break()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Wirkungen auf Herz-Kreislauf")
@writer.send_hr()
@writer.send_line_break()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Herzjagen.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Sehr selten:")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_flowing_data(" Hitzewallung, Migr\344ne, Ohnmacht, Hypotonie.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Sonstige")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Gelenkbeschwerden, Gelenkschwellung.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Sehr selten:")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_flowing_data(" allgemeines Schw\344chegef\374hl, Muskelschmerzen, Myasthenie, Sehnenscheidenentz\374ndung, Photosensibilit\344t,")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("vor\374bergehende Einschr\344nkung der Nierenfunktion bis hin zum vor\374bergehenden Nierenversagen, Tinnitus, Schwerh\366rigkeit,")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("besonders im Hochtonbereich, meist vor\374bergehend.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("In einzelnen F\344llen wurde w\344hrend der Gabe von Ciprofloxacin eine Achillotendinitis beobachtet. Einzelne F\344lle einer teilweise")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("oder vollst\344ndigen Ruptur der Achillessehne wurden vor allem von \344lteren Patienten berichtet, bei denen eine systemische")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Behandlung mit Glucocorticosteroiden vorausgegangen war. Daher sollte bei Zeichen einer Achillotendinitis (z.B. schmerzvolle")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Schwellung) Ciprofloxacin abgesetzt werden.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Wirkungen auf Blut und Blutbestandteile")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Eosinophilie, Leukozytopenie, Granulozytopenie, An\344mie, Thrombozytopenie.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Sehr selten:")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_flowing_data(" Leukozytose, Thrombozytose, h\344molytische An\344mie, ver\344nderte Prothrombinwerte, Panzytopenie,")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Knochenmarkdepression.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Lokale Reaktionen")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Sehr selten:")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_flowing_data(" Phlebitis.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Nach der intraven\366sen Verabreichung von Ciprofloxacin wurden lokale Reaktionen beobachtet. Diese Reaktionen sind h\344ufiger,")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("wenn die Infusionsdauer 30 Minuten oder weniger betr\344gt. Sie k\366nnen als lokale Hautreaktionen auftreten, die nach Beendigung")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("der Infusion rasch wieder verschwinden. Weitere intraven\366se Infusionen sind nicht kontraindiziert, es sei denn, die Reaktionen")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("treten erneut auf oder verschlimmern sich.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Einfluss auf Labor/Urinsediment")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Besonders bei Patienten mit vorgesch\344digter Leber kann es zu einem vor\374bergehenden Anstieg der Transaminasen, LDH und")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("der alkalischen Phosphatase kommen; vor\374bergehender Anstieg von Harnstoff, Kreatinin und Bilirubin im Serum; in Einzelf\344llen:")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Hyperglyk\344mie, Kristallurie, H\344maturie, erh\366hte Amylase und Lipase.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F2
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "478"
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
      :italicangle: "-15"
      :fontname: /Arial-BoldItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 74
    src: |-
      74 0 obj
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
  :widths: 
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
  - "278"
  - "278"
  - "556"
  - "556"
  - "556"
  - "0"
  - "0"
  - "0"
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
  - "722"
  - "778"
  - "667"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 278 278 556 556 556 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 722 722 0 722 667 611 778 722 278 0 722 0 833 722 778 667 0 0 667 0 722 667
  944 0 0 611 0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611
  611 0 389 556 333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0
  0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 74 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("\334berdosierung")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Bei Vorkommen einer akuten, exzessiven \334berdosierung wurde in einigen F\344llen eine reversible Nierentoxit\344t beobachtet.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Abgesehen von den \374blichen Notfallmassnahmen empfiehlt es sich, die Nierenfunktion zu \374berwachen und Magnesium oder")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Calcium enthaltende Antazida zu geben, welche die Resorption von Ciprofloxacin verringern. Durch H\344mo- oder Peritonealdialyse")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("wird nur ein kleiner Prozentsatz von Ciprofloxacin (<10%) aus dem K\366rper entfernt.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Auf eine ausreichende Fl\374ssigkeitszufuhr ist zu achten, um eine Kristallurie zu vermeiden.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F2
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "478"
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
      :italicangle: "-15"
      :fontname: /Arial-BoldItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 74
    src: |-
      74 0 obj
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
  :widths: 
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
  - "278"
  - "278"
  - "556"
  - "556"
  - "556"
  - "0"
  - "0"
  - "0"
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
  - "722"
  - "778"
  - "667"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 278 278 556 556 556 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 722 722 0 722 667 611 778 722 278 0 722 0 833 722 778 667 0 0 667 0 722 667
  944 0 0 611 0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611
  611 0 389 556 333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0
  0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 74 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Eigenschaften/Wirkungen")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("ATC-Code: J01MA02")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Wirkungsmechanismus")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Ciprofloxacin Sandoz i.v. ist ein Antibiotikum aus der Gruppe der Chinolone. Es besitzt eine antibakterielle Wirkung gegen ein")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Spektrum von gramnegativen und grampositiven Bakterien.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Pharmakodynamik")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Ciprofloxacin Sandoz i.v. verhindert, dass die f\374r den normalen Stoffwechsel des Bakteriums notwendige Information vom")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Chromosom abgelesen werden kann. Dies f\374hrt zu einer schnellen Abnahme der Vermehrungsf\344higkeit der Bakterien. Die Wirkung")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("von Ciprofloxacin ist bakterizid.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Ciprofloxacin Sandoz i.v. zeichnet sich ferner dadurch aus, dass aufgrund seiner besonderen Wirkungsweise keine generelle")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Parallelresistenz zu allen anderen Antibiotika ausserhalb der Chinolon-Gruppe besteht. Somit ist Ciprofloxacin Sandoz i.v. z.T.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("auch wirksam bei solchen Bakterien, die resistent gegen z.B. Aminoglykoside, Penicilline, Cephalosporine, Tetracycline und")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("andere Antibiotika sind.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Mikrobiologie")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Die folgenden Erreger sind empfindlich (MHK")
@writer.send_flowing_data("90")
@writer.send_flowing_data(" <1 \265g/ml)")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("E. coli, Shigella, Salmonella, Citrobacter, Klebsiella, Enterobacter, Serratia, Hafnia, Edwardsiella, Proteus (Indol-pos. und -neg.),")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Providencia, Morganella, Yersinia; Vibrio, Aeromonas, Plesiomonas, Pasteurella, Haemophilus, Campylobacter, Pseudomonas,")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Legionella, Neisseria, Branhamella, Acinetobacter, Brucella; Listeria, Staphylococcus, Corynebacterium, Chlamydia.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Unterschiedlich empfindlich (intermedi\344r) sind (MHK")
@writer.send_flowing_data("90")
@writer.send_flowing_data(" = 1\2264 \265g/ml)")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Gardnerella, Flavobacterium, Alcaligenes, Streptococcus agalactiae, Enterococcus faecalis, Streptococcus pyogenes,")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Streptococcus pneumoniae, Streptococci der Gruppe viridans, Mycoplasma hominis, Mycobacterium tuberculosis und")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Mycobacterium fortuitum.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Meist resistent sind (MHK")
@writer.send_flowing_data("90")
@writer.send_flowing_data(" >4 \265g/ml)")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Enterococcus faecium, Ureaplasma urealyticum, Nocardia asteroides.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Anaerobier sind bis auf einige Ausnahmen m\344ssig empfindlich (z.B. Peptococcus, Peptostreptococcus) bis resistent (z.B.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Bacteroides).")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Gegen Treponema pallidum ist Ciprofloxacin nicht wirksam.")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Seite 4")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_page()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.new_fontsize(-8.0)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Fachinformation des Arzneimittel-Kompendium der Schweiz\256")
@writer.send_flowing_data(" ")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_hr()
@writer.send_line_break()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Resistenz")
@writer.send_hr()
@writer.send_line_break()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Resistenzentwicklung gegen\374ber Ciprofloxacin \226 wie auch gegen\374ber anderen Chinolonen \226 wurde bei Staphylococcus spp.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("beobachtet. Das gilt insbesondere f\374r Methicillin-resistente St\344mme von S. aureus. Eine Zunahme der Resistenz wurde ebenfalls")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("bei Pseudomonas aeruginosa beschrieben.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Wenn man die Literatur sorgf\344ltig analysiert, zeigt sich, dass insbesondere solche Patienten gef\344hrdet sind, die \374ber lange Zeit")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("eine Antibiotikatherapie erhalten m\374ssen, wie bei zystischer Fibrose oder Osteomyelitis. \304hnlich ist die Situation bei besonders")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("infektionsgef\344hrdeten Patienten einzusch\344tzen, die aus prophylaktischen oder therapeutischen Gr\374nden eine intensive")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Antibiotikatherapie ben\366tigen (z.B. Leuk\344mie-Patienten, bei denen eine selektive Suppression der Darmflora durchgef\374hrt wird;")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("polytraumatisierte oder chirurgische Patienten, die \374ber l\344ngere Zeit intensivmedizinischer Massnahmen bed\374rfen).")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Der Anteil resistenter Populationen unterliegt grossen lokalen Schwankungen. Eine regelm\344ssige \334berwachung der")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Resistenzsituation ist daher empfehlenswert.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("\334ber Fluorochinolon-resistente Campylobacter-St\344mme wurde im Zusammenhang mit dem weitverbreiteten Einsatz in der")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Gefl\374gelindustrie berichtet.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Der oder die Mechanismen der Resistenzentwicklung gegen\374ber Ciprofloxacin konnte bisher nicht endg\374ltig gekl\344rt werden.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Jedoch kommt es offensichtlich bei einigen Organismen zu Mutationen, die eine Ver\344nderung der A-Untereinheit der (ATP-")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("hydrolisierenden) DNA-Topoisomerase ausl\366sen (die auch als DNA-Gyrase bezeichnet wird). Resistenz kann auch durch eine")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Ver\344nderung der \344usseren Membranproteine (Porine) und/oder andere Faktoren zustande kommen, die die Permeabilit\344t des")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Organismus f\374r die Substanz beeinflussen. Nach derzeitigem Kenntnisstand ist die Resistenz gegen\374ber Ciprofloxacin")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("ausschliesslich chromosomal bedingt und damit nicht \374bertragbar.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Zwischen den Fluorochinolonen liegt \374blicherweise Kreuzresistenz vor (z.B. Ciprofloxacin, Enoxacin, Norfloxacin, Ofloxacin).")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Zwischen Ciprofloxacin und anderen antimikrobiellen Substanzen (Aminoglykoside, ")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :tounicode: !ruby/object:Rpdf2txt::Stream 
    attributes: 
      :filter: /FlateDecode
      :length: "207"
    decoder: 
    oid: 78
    src: !binary |
      NzggMCBvYmoKPDwKL0xlbmd0aCAyMDcKL0ZpbHRlciAvRmxhdGVEZWNvZGUg
      Pj4Kc3RyZWFtCnjaVVAxbsMwDNz1Co4tMsh2kM3IUBcBPLQN4n5AlmhXQEwJ
      tDz495EUx0AHkbjjHXiUbNrPlmwAeWWnOwwwWDKMs1tYI/Q4WoKyAmN12FCu
      elIeRDR36xxwamlwUNfyFmdz4BXeLqdD8Q7yhw2ypTEREXaL93eckAIUQjZf
      yn+rCUEmNRgcntzv6hGqjMttnTM4e6WRFY0IdVGVp/OrAZL5L3jZ+kH/KRa7
      /PhRnUVUb3zypTv2HHphjtnysTlJymAJ9//wzqdt6YkHNQlm5GVuZHN0cmVh
      bQplbmRvYmo=

    target_encoding: latin1
  :name: /F5
  :subtype: /Type0
  :basefont: Symbol
  :encoding: /Identity-H
  :descendantfonts: 
  - 77 0 R
  :type: /Font
decoder: 
oid: 23
src: |-
  23 0 obj
  <<
  /Type /Font
  /Name /F5
  /Subtype /Type0
  /BaseFont /JMEYWZ+ArialMT
  /Encoding /Identity-H
  /DescendantFonts[ 77 0 R]
  /ToUnicode 78 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_flowing_data("?")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_flowing_data("-Laktam-Antibiotika, Sulfonamide")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("einschliesslich Cotrimoxazol, Makrolide, Tetracycline), tritt grunds\344tzlich keine Kreuzresistenz auf.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Die zuvor genannte herabgesetzte Permeabilit\344t ist m\366glicherweise daf\374r verantwortlich, dass selten St\344mme von Pseudomonas")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("aeruginosa oder aus der Gruppe der Enterobacteriaceae beobachtet wurden, die sowohl gegen\374ber Ciprofloxacin als auch nicht")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("verwandten Substanzen (z.B. ")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :tounicode: !ruby/object:Rpdf2txt::Stream 
    attributes: 
      :filter: /FlateDecode
      :length: "207"
    decoder: 
    oid: 78
    src: !binary |
      NzggMCBvYmoKPDwKL0xlbmd0aCAyMDcKL0ZpbHRlciAvRmxhdGVEZWNvZGUg
      Pj4Kc3RyZWFtCnjaVVAxbsMwDNz1Co4tMsh2kM3IUBcBPLQN4n5AlmhXQEwJ
      tDz495EUx0AHkbjjHXiUbNrPlmwAeWWnOwwwWDKMs1tYI/Q4WoKyAmN12FCu
      elIeRDR36xxwamlwUNfyFmdz4BXeLqdD8Q7yhw2ypTEREXaL93eckAIUQjZf
      yn+rCUEmNRgcntzv6hGqjMttnTM4e6WRFY0IdVGVp/OrAZL5L3jZ+kH/KRa7
      /PhRnUVUb3zypTv2HHphjtnysTlJymAJ9//wzqdt6YkHNQlm5GVuZHN0cmVh
      bQplbmRvYmo=

    target_encoding: latin1
  :name: /F5
  :subtype: /Type0
  :basefont: Symbol
  :encoding: /Identity-H
  :descendantfonts: 
  - 77 0 R
  :type: /Font
decoder: 
oid: 23
src: |-
  23 0 obj
  <<
  /Type /Font
  /Name /F5
  /Subtype /Type0
  /BaseFont /JMEYWZ+ArialMT
  /Encoding /Identity-H
  /DescendantFonts[ 77 0 R]
  /ToUnicode 78 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_flowing_data("?")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_flowing_data("-Laktamen, Aminoglykosiden) resistent waren.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Die Kombination von Ciprofloxacin Sandoz i.v. mit anderen antibakteriell wirksamen Substanzen ergibt ")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_flowing_data("in vitro")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_flowing_data(" \374berwiegend")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("additive oder indifferente Effekte.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("MHK")
@writer.send_flowing_data("50")
@writer.send_flowing_data("- und MHK")
@writer.send_flowing_data("90")
@writer.send_flowing_data("-Werte von Ciprofloxacin Sandoz i.v. f\374r eine Auswahl von grampositiven und gramnegativen Bakterien.")
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("MHK")
@writer.send_flowing_data("50")
@writer.send_flowing_data(" = Minimale Hemmkonzentrationen 50%.")
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("MHK")
@writer.send_flowing_data("90")
@writer.send_flowing_data(" = Minimale Hemmkonzentrationen 90%.")
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Bei durch m\344ssig empfindliche Keime verursachten Infektionen ist die Durchf\374hrung eines Empfindlichkeitstestes zu empfehlen,")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("um eine eventuelle Resistenz ausschliessen zu k\366nnen. Die Empfindlichkeit auf Ciprofloxacin Sandoz i.v. kann anhand von")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("standardisierten Verfahren, wie sie beispielsweise vom Clinical and Laboratory Standards Institute (CLSI) empfohlen werden, mit")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Disk- oder Verd\374nnungstests bestimmt werden. Dabei werden vom CLSI die folgenden Parameter als Empfindlichkeitskriterien")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("empfohlen:")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F4
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "43"
      :avgwidth: "600"
      :fontbbox: 
      - "-21"
      - "-680"
      - "638"
      - "1021"
      :italicangle: "0"
      :fontname: /CourierNewPSMT
      :stemv: "0"
      :ascent: "832"
      :maxwidth: "659"
      :capheight: "832"
      :type: /FontDescriptor
      :descent: "-300"
    decoder: 
    oid: 76
    src: |-
      76 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 832
      /CapHeight 832
      /Descent -300
      /Flags 43
      /FontBBox[ -21 -680 638 1021 ]
      /FontName /CourierNewPSMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 600
      /MaxWidth 659
      >>
      endobj
    target_encoding: latin1
  :basefont: /CourierNewPSMT
  :widths: 
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "0"
  - "600"
  - "0"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  :encoding: /WinAnsiEncoding
  :type: /Font
decoder: 
oid: 10
src: |-
  10 0 obj
  <<
  /Type /Font
  /Name /F4
  /Subtype /TrueType
  /BaseFont /CourierNewPSMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 600 0 0 0 0 600 0 0 600 600 0 0 600 600 600 600 600 600 600 600 600 600
  600 600 600 600 0 0 600 0 600 0 0 600 600 600 600 600 600 600 600 600 600 600 600
  600 600 600 600 0 600 600 600 600 600 0 0 600 600 0 0 0 0 0 0 600 600 600 600 600
  600 600 600 600 600 600 600 600 600 600 600 0 600 600 600 600 600 600 600 600 600
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 600 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 76 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("                 Disktest (5 \265g)     Verd\374nnungstest")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("                 Durchmesser (mm)    MHK (mg/l)     ")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Sensibel         >21                 <1             ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Intermedi\344r      16\22620               2              ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Resistent        <14                 >4             ")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Keime                      Zahl der  MHK 50   MHK 90")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("                           Isolate   (mg/l)   (mg/l)")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Enterobakterien                                     ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Escherichia coli           6315      0,03     0,10  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Shigella spp.              1664      0,03     0,04  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Salmonella spp.            1770      0,04     0,06  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Citrobacter spp.           1602      0,04     0,10  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Klebsiella spp.            3500      0,04     0,24  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Enterobacter spp.          3533      0,04     0,19  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Serratia spp.              1828      0,10     0,70  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Hafnia alvei               37        0,02     0,06  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Edwardsiella tarda         29        0,06     0,06  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Proteus mirabilis          2372      0,03     0,11  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Proteus vulgaris           689       0,03     0,05  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Providencia alcalifaciens  62        0,02     0,05  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Providencia rettgeri       310       0,13     1,57  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Providencia stuartii       568       0,26     1,69  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Morganella morganii        912       0,02     0,12  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Yersinia spp.              550       0,03     0,04  ")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Gramnegative Erreger                                ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Vibrio ssp.                162       0,53     0,54  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Aeromonas ssp.             367       0,02     0,03  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Plesiomonas shigelloides   44        0,03     0,03  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Pasteurella multocida      20        0,01     0,02  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Haemophilus influenzae     1158      0,01     0,02  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Haemophilus ducreyi        325       0,01     0,03  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Gardnerella vaginalis      230       1,33     2,68  ")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Seite 5")
@writer.send_hr()
@writer.send_line_break()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F4
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "43"
      :avgwidth: "600"
      :fontbbox: 
      - "-21"
      - "-680"
      - "638"
      - "1021"
      :italicangle: "0"
      :fontname: /CourierNewPSMT
      :stemv: "0"
      :ascent: "832"
      :maxwidth: "659"
      :capheight: "832"
      :type: /FontDescriptor
      :descent: "-300"
    decoder: 
    oid: 76
    src: |-
      76 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 832
      /CapHeight 832
      /Descent -300
      /Flags 43
      /FontBBox[ -21 -680 638 1021 ]
      /FontName /CourierNewPSMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 600
      /MaxWidth 659
      >>
      endobj
    target_encoding: latin1
  :basefont: /CourierNewPSMT
  :widths: 
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "0"
  - "600"
  - "0"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  :encoding: /WinAnsiEncoding
  :type: /Font
decoder: 
oid: 10
src: |-
  10 0 obj
  <<
  /Type /Font
  /Name /F4
  /Subtype /TrueType
  /BaseFont /CourierNewPSMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 600 0 0 0 0 600 0 0 600 600 0 0 600 600 600 600 600 600 600 600 600 600
  600 600 600 600 0 0 600 0 600 0 0 600 600 600 600 600 600 600 600 600 600 600 600
  600 600 600 600 0 600 600 600 600 600 0 0 600 600 0 0 0 0 0 0 600 600 600 600 600
  600 600 600 600 600 600 600 600 600 600 600 0 600 600 600 600 600 600 600 600 600
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 600 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 76 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_column()
@writer.send_page()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.new_fontsize(-8.0)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Fachinformation des Arzneimittel-Kompendium der Schweiz\256")
@writer.send_flowing_data(" ")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_hr()
@writer.send_line_break()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F4
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "43"
      :avgwidth: "600"
      :fontbbox: 
      - "-21"
      - "-680"
      - "638"
      - "1021"
      :italicangle: "0"
      :fontname: /CourierNewPSMT
      :stemv: "0"
      :ascent: "832"
      :maxwidth: "659"
      :capheight: "832"
      :type: /FontDescriptor
      :descent: "-300"
    decoder: 
    oid: 76
    src: |-
      76 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 832
      /CapHeight 832
      /Descent -300
      /Flags 43
      /FontBBox[ -21 -680 638 1021 ]
      /FontName /CourierNewPSMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 600
      /MaxWidth 659
      >>
      endobj
    target_encoding: latin1
  :basefont: /CourierNewPSMT
  :widths: 
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "0"
  - "600"
  - "0"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  :encoding: /WinAnsiEncoding
  :type: /Font
decoder: 
oid: 10
src: |-
  10 0 obj
  <<
  /Type /Font
  /Name /F4
  /Subtype /TrueType
  /BaseFont /CourierNewPSMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 600 0 0 0 0 600 0 0 600 600 0 0 600 600 600 600 600 600 600 600 600 600
  600 600 600 600 0 0 600 0 600 0 0 600 600 600 600 600 600 600 600 600 600 600 600
  600 600 600 600 0 600 600 600 600 600 0 0 600 600 0 0 0 0 0 0 600 600 600 600 600
  600 600 600 600 600 600 600 600 600 600 600 0 600 600 600 600 600 600 600 600 600
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 600 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 76 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Keime                      Zahl der  MHK 50   MHK 90")
@writer.send_hr()
@writer.send_line_break()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F4
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "43"
      :avgwidth: "600"
      :fontbbox: 
      - "-21"
      - "-680"
      - "638"
      - "1021"
      :italicangle: "0"
      :fontname: /CourierNewPSMT
      :stemv: "0"
      :ascent: "832"
      :maxwidth: "659"
      :capheight: "832"
      :type: /FontDescriptor
      :descent: "-300"
    decoder: 
    oid: 76
    src: |-
      76 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 832
      /CapHeight 832
      /Descent -300
      /Flags 43
      /FontBBox[ -21 -680 638 1021 ]
      /FontName /CourierNewPSMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 600
      /MaxWidth 659
      >>
      endobj
    target_encoding: latin1
  :basefont: /CourierNewPSMT
  :widths: 
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "0"
  - "600"
  - "0"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  :encoding: /WinAnsiEncoding
  :type: /Font
decoder: 
oid: 10
src: |-
  10 0 obj
  <<
  /Type /Font
  /Name /F4
  /Subtype /TrueType
  /BaseFont /CourierNewPSMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 600 0 0 0 0 600 0 0 600 600 0 0 600 600 600 600 600 600 600 600 600 600
  600 600 600 600 0 0 600 0 600 0 0 600 600 600 600 600 600 600 600 600 600 600 600
  600 600 600 600 0 600 600 600 600 600 0 0 600 600 0 0 0 0 0 0 600 600 600 600 600
  600 600 600 600 600 600 600 600 600 600 600 0 600 600 600 600 600 600 600 600 600
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 600 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 76 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("                           Isolate   (mg/l)   (mg/l)")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Eikenella corrodens        44        0,01     0,02  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Capnocytophaga spp.        249       0,09     0,18  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Pseudomonas aeruginosa     6546      0,20     0,71  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("\226 maltophilia              590       2,22     6,22  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("\226 fluorescens              118       0,19     0,81  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("\226 cepacia                  271       5,04     9,35  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("\226 putida                   116       0,19     2,52  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("\226 pseudomallei             80        3,20     7,05  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("\226 acidovorans              49        0,18     0,37  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("\226 putrefaciens             32        0,11     0,76  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("\226 stutzeri                 47        0,14     0,28  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Agrobacterium spp.         20        0,06     0,06  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Legionella spp.            128       0,30     0,38  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Neisseria gonorrhoeae      1899      0,00     0,01  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Neisseria meningitidis     266       0,01     0,01  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Branhamella catarrhalis    209       0,05     0,10  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Acinetobacter spp.         1862      0,36     1,21  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Flavobacterium spp.        88        2,17     3,60  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Alcaligenes spp.           68        0,52     2,58  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Brucella melitensis        179       0,36     0,72  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Bordetella spp.            136       0,46     0,54  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Campylobacter spp.         1151      0,16     0,68  ")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Grampositive Erreger                                ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Staphylococcus aureus      3580      0,32     0,62  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("\226 epidermidis              1304      0,18     0,35  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("\226 saprophyticus            230       0,38     0,47  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("\226 haemolyticus             91        0,20     0,35  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("\226 hominis                  61        0,17     0,33  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Streptococcus pyogenes     524       0,85     2,22  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("\226 agalactiae               976       0,70     1,32  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("\226 pneumoniae               974       1,31     1,97  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("\226 avium                    32        1        1,38  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("\226 bovis                    83        1,85     3,15  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("\226 viridans                 350       1,60     3,42  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Enterococcus faecalis      2726      0,90     1,69  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("\226 faecium                  131       1,89     3,86  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Bacillus spp.              126       0,22     0,62  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Lactobacillus spp.         62        4        16    ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Listeria monocytogenes     449       0,78     1,33  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Corynebacterium spp.       176       0,17     0,88  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Corynebacterium JK         102       0,54     0,98  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Actinomyces spp.           15        1,40     8     ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Propionibacterium acnes    64        0,96     2,32  ")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Anaerobier                                          ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Bacteroides spp.           3265      4,25     12    ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Mobiluncus spp.            21        2,33     2,57  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Fusobacterium spp.         144       1,91     11    ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Veillonella spp.           37        0,18     1,96  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Peptococcus spp.           182       1,11     2,58  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Peptostreptococcus spp.    448       1,15     4,72  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Clostridium spp.           1247      5,15     13    ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Eubacterium spp.           62        4,29     11    ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Bifidobacterium spp.       14        4        20    ")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Sonstige Erreger                                    ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Borrelia burgdorferi       10        1        2     ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Chlamydia trachomatis      67        0,99     1,63  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Mycoplasma hominis         139       0,64     1,32  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Ureaplasma urealyticum     168       5,09     9,61  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Mycobacterium tuberculosis 649       0,73     1,62  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("\226 avium                    135       29       49    ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("\226 chelonei                 87        5,34     27    ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("\226 fortuitum                139       0,40     1,11  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("\226 intracellulare           54        7,85     9,63  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("\226 kansasii                 118       4,05     30    ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("\226 marinum                  13        1,73     2,70  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("\226 xenopi                   62        0,70     2,29  ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Nocardia spp.              164       2,25     19    ")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Rhodococcus spp.           10        0,12     1     ")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Seite 6")
@writer.send_hr()
@writer.send_line_break()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F4
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "43"
      :avgwidth: "600"
      :fontbbox: 
      - "-21"
      - "-680"
      - "638"
      - "1021"
      :italicangle: "0"
      :fontname: /CourierNewPSMT
      :stemv: "0"
      :ascent: "832"
      :maxwidth: "659"
      :capheight: "832"
      :type: /FontDescriptor
      :descent: "-300"
    decoder: 
    oid: 76
    src: |-
      76 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 832
      /CapHeight 832
      /Descent -300
      /Flags 43
      /FontBBox[ -21 -680 638 1021 ]
      /FontName /CourierNewPSMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 600
      /MaxWidth 659
      >>
      endobj
    target_encoding: latin1
  :basefont: /CourierNewPSMT
  :widths: 
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "0"
  - "600"
  - "0"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  :encoding: /WinAnsiEncoding
  :type: /Font
decoder: 
oid: 10
src: |-
  10 0 obj
  <<
  /Type /Font
  /Name /F4
  /Subtype /TrueType
  /BaseFont /CourierNewPSMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 600 0 0 0 0 600 0 0 600 600 0 0 600 600 600 600 600 600 600 600 600 600
  600 600 600 600 0 0 600 0 600 0 0 600 600 600 600 600 600 600 600 600 600 600 600
  600 600 600 600 0 600 600 600 600 600 0 0 600 600 0 0 0 0 0 0 600 600 600 600 600
  600 600 600 600 600 600 600 600 600 600 600 0 600 600 600 600 600 600 600 600 600
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 600 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 76 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_column()
@writer.send_page()
@writer.send_column()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.new_fontsize(-8.0)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("Fachinformation des Arzneimittel-Kompendium der Schweiz\256")
@writer.send_flowing_data(" ")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_hr()
@writer.send_line_break()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F4
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "43"
      :avgwidth: "600"
      :fontbbox: 
      - "-21"
      - "-680"
      - "638"
      - "1021"
      :italicangle: "0"
      :fontname: /CourierNewPSMT
      :stemv: "0"
      :ascent: "832"
      :maxwidth: "659"
      :capheight: "832"
      :type: /FontDescriptor
      :descent: "-300"
    decoder: 
    oid: 76
    src: |-
      76 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 832
      /CapHeight 832
      /Descent -300
      /Flags 43
      /FontBBox[ -21 -680 638 1021 ]
      /FontName /CourierNewPSMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 600
      /MaxWidth 659
      >>
      endobj
    target_encoding: latin1
  :basefont: /CourierNewPSMT
  :widths: 
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "0"
  - "600"
  - "0"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  :encoding: /WinAnsiEncoding
  :type: /Font
decoder: 
oid: 10
src: |-
  10 0 obj
  <<
  /Type /Font
  /Name /F4
  /Subtype /TrueType
  /BaseFont /CourierNewPSMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 600 0 0 0 0 600 0 0 600 600 0 0 600 600 600 600 600 600 600 600 600 600
  600 600 600 600 0 0 600 0 600 0 0 600 600 600 600 600 600 600 600 600 600 600 600
  600 600 600 600 0 600 600 600 600 600 0 0 600 600 0 0 0 0 0 0 600 600 600 600 600
  600 600 600 600 600 600 600 600 600 600 600 0 600 600 600 600 600 600 600 600 600
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 600 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 76 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_column()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("Ciprofloxacin bei Milzbrand")
@writer.send_hr()
@writer.send_line_break()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_column()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("Zur Absch\344tzung der therapeutischen Wirksamkeit beim Menschen wurden stellvertretend die bei Menschen gemessenen")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("Serumkonzentrationen als so genannter Surrogatparameter f\374r die Anwendung von Ciprofloxacin nach Inhalation von")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("Milzbranderregern herangezogen.")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("Bei Erwachsenen wurden nach Verabreichung der empfohlenen Dosen Ciprofloxacin durchschnittliche Plasmaspiegel erreicht,")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("die gleich oder oberhalb der bei Rhesusaffen gemessenen liegen, die Milzbrandsporen inhaliert hatten und danach mit")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("Ciprofloxacin behandelt wurden. Der Unterschied in der Mortalit\344t der mit Ciprofloxacin behandelten Tiere zur unbehandelten")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("Kontrollgruppe war zugunsten der behandelten Tiere statistisch signifikant (p= 0,001).")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("Die Pharmakokinetik von Ciprofloxacin beim Menschen ist umfassend untersucht (siehe auch \253Pharmakokinetik\273).")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("Bei ")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_flowing_data("Erwachsenen")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_flowing_data(" wurden im Steady State nach intraven\366ser Applikation von 400 mg alle 12 Stunden von 4,56 \265g/ml gemessen.")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("Es wurde im Steady State 12 Stunden nach der letzten Applikation die so genannten Trough-Spiegel mit durchschnittlich 0,2 \265g/")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("ml bestimmt.")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("Bei 10 Kindern im Alter von 6 bis 16 Jahren wurden nach zweimaliger Infusion von 10 mg/kg \374ber 30 Minuten im Abstand von 12")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("Stunden Serumspitzenkonzentrationen von 8,3 \265g/ml erreicht, die Trough-Konzentrationen variierten zwischen 0,09 und 0,26 \265g/")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("ml.")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("Vertr\344glichkeitsdaten nach Langzeitgabe an Kindern, inklusive der Wirkungen auf das Knorpelgewebe sind nur sehr begrenzt")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("verf\374gbar (siehe Kapitel \253Unerw\374nschte Wirkungen\273).")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("In einer Plazebo-kontrollierten Studie wurden Rhesusaffen einer durchschnittlichen zu inhalierenden Dosis von 11 LD")
@writer.send_flowing_data("50")
@writer.send_flowing_data(" (etwa")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("5,5\327 10")
@writer.send_flowing_data("5")
@writer.send_flowing_data(", Bandbreite 5\22630 LD")
@writer.send_flowing_data("50")
@writer.send_flowing_data(") Milzbrandsporen ausgesetzt. Die minimale Hemmkonzentration (MHK90) f\374r den eingesetzten")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("B. anthracis-Stamm war mit 0,08 \265g/ml bestimmt worden.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F2
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "478"
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
      :italicangle: "-15"
      :fontname: /Arial-BoldItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 74
    src: |-
      74 0 obj
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
  :widths: 
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
  - "278"
  - "278"
  - "556"
  - "556"
  - "556"
  - "0"
  - "0"
  - "0"
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
  - "722"
  - "778"
  - "667"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 278 278 556 556 556 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 722 722 0 722 667 611 778 722 278 0 722 0 833 722 778 667 0 0 667 0 722 667
  944 0 0 611 0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611
  611 0 389 556 333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0
  0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 74 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Pharmakokinetik")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Absorption")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Nach einer Infusion wurden maximale Serumkonzentrationen am Ende der Infusionen erreicht (1,8 mg/l nach Infusion von 100 mg")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("w\344hrend 30 Min.; 3,4 mg/l nach Infusion von 200 mg w\344hrend 30 Min.; 3,9 mg/l nach Infusion von 400 mg w\344hrend 60 Min.). Die")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Pharmakokinetik erwies sich dabei als linear.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Distribution")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Ciprofloxacin ist an den Orten der Infektion, n\344mlich in den Fl\374ssigkeiten und Geweben des K\366rpers, in mehrfach h\366heren")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Konzentrationen enthalten als im Serum.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Das Verteilungsvolumen von Ciprofloxacin betr\344gt im \253Steady state\273 2\2263 l/kg.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Da die Proteinbindung von Ciprofloxacin gering ist (20\22630%) und die Substanz im Blutplasma \374berwiegend in nicht ionisierter")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Form vorliegt, kann nahezu die gesamte Menge der applizierten Dosis frei in den Extravasalraum diffundieren. Auf diese Weise")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("k\366nnen die Konzentrationen in bestimmten K\366rperfl\374ssigkeiten und Geweben die korrespondierenden Serumspiegel deutlich")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("\374berschreiten.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Nur geringe Konzentrationen von Ciprofloxacin gelangen in den cerebrospinalen Liquor, die Maximalkonzentration betr\344gt etwa")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("6\22610% derjenigen des Serums.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Nach i.v. Gabe sind die Ciprofloxacinkonzentrationen in der Gallenfl\374ssigkeit um ein Mehrfaches h\366her als im Serum.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Metabolismus/Elimination")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Die durchschnittliche Serumhalbwertszeit betr\344gt ca. 4 Stunden. Nach intraven\366ser Infusion werden 71% der verabreichten Dosis")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("mit dem Urin und weitere 17,8% mit den Faeces ausgeschieden. Die nichtrenale Ausscheidung von Ciprofloxacin erfolgt")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("haupts\344chlich durch aktive transintestinale Sekretion als auch durch Metabolisierung. Ca. 10\22620% einer Einzeldosis werden als")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Metabolite ausgeschieden.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Die im einzelnen wiedergefundenen Mengen der Metaboliten sind nachstehend aufgef\374hrt.")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F4
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "43"
      :avgwidth: "600"
      :fontbbox: 
      - "-21"
      - "-680"
      - "638"
      - "1021"
      :italicangle: "0"
      :fontname: /CourierNewPSMT
      :stemv: "0"
      :ascent: "832"
      :maxwidth: "659"
      :capheight: "832"
      :type: /FontDescriptor
      :descent: "-300"
    decoder: 
    oid: 76
    src: |-
      76 0 obj
      <<
      /Type /FontDescriptor
      /Ascent 832
      /CapHeight 832
      /Descent -300
      /Flags 43
      /FontBBox[ -21 -680 638 1021 ]
      /FontName /CourierNewPSMT
      /ItalicAngle 0
      /StemV 0
      /AvgWidth 600
      /MaxWidth 659
      >>
      endobj
    target_encoding: latin1
  :basefont: /CourierNewPSMT
  :widths: 
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "0"
  - "600"
  - "0"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "0"
  - "600"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "600"
  :encoding: /WinAnsiEncoding
  :type: /Font
decoder: 
oid: 10
src: |-
  10 0 obj
  <<
  /Type /Font
  /Name /F4
  /Subtype /TrueType
  /BaseFont /CourierNewPSMT
  /FirstChar 32
  /LastChar 252
  /Widths[ 600 0 0 0 0 600 0 0 600 600 0 0 600 600 600 600 600 600 600 600 600 600
  600 600 600 600 0 0 600 0 600 0 0 600 600 600 600 600 600 600 600 600 600 600 600
  600 600 600 600 0 600 600 600 600 600 0 0 600 600 0 0 0 0 0 0 600 600 600 600 600
  600 600 600 600 600 600 600 600 600 600 600 0 600 600 600 600 600 600 600 600 600
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0 600 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 600 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 76 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("Ausscheidung (in % der Ciprofloxacin-Dosis)         ")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("                     i.v. Anwendung                 ")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("Substanz             Harn        F\344ces              ")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("Ciprofloxacin        61,5        15,2               ")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("Desethylencipro-                                    ")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data(" floxaxin            1,3         0,5                ")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("Sulfociprofloxacin   2,6         1,3                ")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("Oxociprofloxacin     5,6         0,8                ")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("Summe                71,0        17,8               ")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("Ein 4. Abbauprodukt (Formylciprofloxacin) wurde zu weniger als 0,1% in nur einigen Proben gefunden.")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("Drei der vier Ciprofloxacin-Metaboliten zeigen eine der Nalidixins\344ure vergleichbare bzw. geringere antibakterielle Aktivit\344t. Der")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("mengenm\344ssig kleinste Metabolit (Formylciprofloxacin) ist gleichzeitig der aktivste und seine Wirksamkeit entspricht weitgehend")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("der von Norfloxacin.")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("Mehr als 90% der renalen Ausscheidung erfolgt in den ersten 24 Stunden. Ein Vergleich der pharmakokinetischen Parameter einer")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("zweimonatigen und dreimonatigen intraven\366sen Gabe erbrachte keinerlei Hinweise einer Kumulation von Ciprofloxacin und seiner")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("Metaboliten.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("Kinetik spezieller Patientengruppen")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("Bei \344lteren Patienten sollte die Kreatinin-Clearance gepr\374ft werden, da die Eliminationshalbwertszeit verl\344ngert sein kann.")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("Bei eingeschr\344nkter Nierenfunktion ist ab einer Kreatinin-Clearance von kleiner als 20 ml/min. die Dosis zu halbieren oder das")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("Dosierungsintervall zu verdoppeln.")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("Aufgrund der geringen Metabolisierungsrate von Ciprofloxacin ist eine Kumulation bei Patienten mit eingeschr\344nkter Leberfunktion")
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("unwahrscheinlich.")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_flowing_data("Seite 7")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_column()
@writer.send_page()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.new_fontsize(-8.0)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Fachinformation des Arzneimittel-Kompendium der Schweiz\256")
@writer.send_flowing_data(" ")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.new_fontsize(-8.0)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Pharmakokinetische Untersuchungen bei Kindern/Jugendlichen mit zystischer Fibrose zeigen, dass die")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Plasmakonzentrationsverl\344ufe bei Kindern und Jugendlichen mit denen von Erwachsenen bei der jeweils empfohlenen Dosierung")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("(parenteral: 10 mg/kg) vergleichbar sind.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F2
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "478"
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
      :italicangle: "-15"
      :fontname: /Arial-BoldItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 74
    src: |-
      74 0 obj
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
  :widths: 
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
  - "278"
  - "278"
  - "556"
  - "556"
  - "556"
  - "0"
  - "0"
  - "0"
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
  - "722"
  - "778"
  - "667"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 278 278 556 556 556 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 722 722 0 722 667 611 778 722 278 0 722 0 833 722 778 667 0 0 667 0 722 667
  944 0 0 611 0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611
  611 0 389 556 333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0
  0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 74 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Pr\344klinische Daten")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("\226")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F2
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "478"
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
      :italicangle: "-15"
      :fontname: /Arial-BoldItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 74
    src: |-
      74 0 obj
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
  :widths: 
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
  - "278"
  - "278"
  - "556"
  - "556"
  - "556"
  - "0"
  - "0"
  - "0"
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
  - "722"
  - "778"
  - "667"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 278 278 556 556 556 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 722 722 0 722 667 611 778 722 278 0 722 0 833 722 778 667 0 0 667 0 722 667
  944 0 0 611 0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611
  611 0 389 556 333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0
  0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 74 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Sonstige Hinweise")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Haltbarkeit")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Das Medikament darf nur bis zu dem auf dem Beh\344lter mit \253EXP\273 bezeichneten Datum verwendet werden.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Besondere Lagerungshinweise")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Bei Raumtemperatur (15\22625 \260C) und vor Licht gesch\374tzt aufbewahren. Nicht im K\374hlschrank lagern.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F3
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "441"
      :fontbbox: 
      - "-517"
      - "-325"
      - "1082"
      - "998"
      :italicangle: "-15"
      :fontname: /Arial-ItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1598"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 75
    src: |-
      75 0 obj
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
  :widths: 
  - "278"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "333"
  - "333"
  - "0"
  - "0"
  - "0"
  - "333"
  - "0"
  - "278"
  - "556"
  - "556"
  - "0"
  - "0"
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  - "278"
  - "0"
  - "584"
  - "584"
  - "584"
  - "0"
  - "0"
  - "667"
  - "667"
  - "722"
  - "722"
  - "667"
  - "0"
  - "778"
  - "722"
  - "0"
  - "500"
  - "667"
  - "556"
  - "833"
  - "722"
  - "0"
  - "667"
  - "0"
  - "722"
  - "667"
  - "0"
  - "722"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  - "556"
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
  - "556"
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /LastChar 252
  /Widths[ 278 0 0 0 0 0 0 0 333 333 0 0 0 333 0 278 556 556 0 0 556 0 0 0 0 556 278
  0 584 584 584 0 0 667 667 722 722 667 0 778 722 0 500 667 556 833 722 0 667 0 722
  667 0 722 0 944 0 0 0 0 0 0 0 0 0 556 556 500 556 556 278 556 556 222 0 500 222 833
  556 556 556 0 333 500 278 556 500 722 500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 576 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 722 0 0 0 0 0 0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 75 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Besondere Hinweise")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Ciprofloxacin Sandoz i.v. Infusion ist zum direkten Gebrauch bestimmt oder kann mit folgenden Infusionsl\366sungen verd\374nnt werden")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("(1:1): mit physiologischer NaCl-L\366sung, Ringer- und Ringer-Lactat-L\366sung, 5%iger und 10%iger Glucosel\366sung.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Aus mikrobiologisch-hygienischen Gr\374nden sollten diese Infusionsl\366sungen direkt nach ihrer Herstellung verwendet werden.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Die Infusion ist \226 sofern die Kompatibilit\344t mit anderen Infusionsl\366sungen/Arzneimitteln nicht erwiesen ist \226 grunds\344tzlich getrennt")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("zu applizieren. Optische Zeichen der Inkompatibilit\344t sind z.B. Ausf\344llung, Tr\374bung, Verf\344rbung.")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Inkompatibilit\344t besteht zu allen Infusionsl\366sungen/Arzneimitteln, die beim pH-Wert der Ciprofloxacin Sandoz i.v.-L\366sungen")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("physikalisch oder chemisch instabil sind (z.B. Penicillin, Heparin-L\366sungen), insbesondere bei Kombination mit alkalisch")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("eingestellten L\366sungen (pH-Wert der Infusionsl\366sung: 3,15\2264,5).")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Da die Infusionsl\366sung lichtempfindlich ist, sollten die Flaschen nur zum Gebrauch aus der Faltschachtel entnommen werden. Bei")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Tageslicht ist die volle Wirksamkeit \374ber 5 Tage gew\344hrleistet.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F2
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "478"
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
      :italicangle: "-15"
      :fontname: /Arial-BoldItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 74
    src: |-
      74 0 obj
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
  :widths: 
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
  - "278"
  - "278"
  - "556"
  - "556"
  - "556"
  - "0"
  - "0"
  - "0"
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
  - "722"
  - "778"
  - "667"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 278 278 556 556 556 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 722 722 0 722 667 611 778 722 278 0 722 0 833 722 778 667 0 0 667 0 722 667
  944 0 0 611 0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611
  611 0 389 556 333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0
  0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 74 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Zulassungsvermerk")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("56906 (Swissmedic).")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F2
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "478"
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
      :italicangle: "-15"
      :fontname: /Arial-BoldItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 74
    src: |-
      74 0 obj
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
  :widths: 
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
  - "278"
  - "278"
  - "556"
  - "556"
  - "556"
  - "0"
  - "0"
  - "0"
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
  - "722"
  - "778"
  - "667"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 278 278 556 556 556 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 722 722 0 722 667 611 778 722 278 0 722 0 833 722 778 667 0 0 667 0 722 667
  944 0 0 611 0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611
  611 0 389 556 333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0
  0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 74 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Zulassungsinhaberin")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Sandoz Pharmaceuticals AG, 6312 Steinhausen/Cham.")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F2
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "106"
      :avgwidth: "478"
      :fontbbox: 
      - "-560"
      - "-377"
      - "1157"
      - "1001"
      :italicangle: "-15"
      :fontname: /Arial-BoldItalicMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "1716"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 74
    src: |-
      74 0 obj
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
  :widths: 
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
  - "278"
  - "278"
  - "556"
  - "556"
  - "556"
  - "0"
  - "0"
  - "0"
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
  - "722"
  - "778"
  - "667"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  /Widths[ 278 0 0 0 0 0 0 0 0 0 0 0 0 0 278 278 556 556 556 0 0 0 0 0 0 556 0 0 0
  0 0 0 0 722 722 0 722 667 611 778 722 278 0 722 0 833 722 778 667 0 0 667 0 722 667
  944 0 0 611 0 0 0 0 0 0 556 611 556 611 556 333 611 611 278 0 556 278 889 611 611
  611 0 389 556 333 611 556 778 0 0 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 722 0 0 0 0 0
  0 0 556 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 611 0 0 0 0 0 611 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 74 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Stand der Information")
font = YAML.load <<-EOF
--- !ruby/object:Rpdf2txt::Font 
attributes: 
  :firstchar: "32"
  :name: /F0
  :subtype: /TrueType
  :lastchar: "252"
  :fontdescriptor: !ruby/object:Rpdf2txt::Unknown 
    attributes: 
      :flags: "42"
      :avgwidth: "441"
      :fontbbox: 
      - "-665"
      - "-325"
      - "2000"
      - "1006"
      :italicangle: "0"
      :fontname: /ArialMT
      :stemv: "0"
      :ascent: "905"
      :maxwidth: "2664"
      :capheight: "905"
      :type: /FontDescriptor
      :descent: "-212"
    decoder: 
    oid: 72
    src: |-
      72 0 obj
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
  :widths: 
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
  - "584"
  - "584"
  - "0"
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
  - "667"
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
  - "556"
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
  - "333"
  - "0"
  - "0"
  - "576"
  - "0"
  - "0"
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
  - "0"
  - "0"
  - "0"
  - "0"
  - "0"
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
  :encoding: /WinAnsiEncoding
  :type: /Font
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
  556 556 556 556 278 278 584 584 0 0 0 667 667 722 722 667 611 778 722 278 500 667
  556 833 722 778 667 0 722 667 611 722 667 944 667 667 611 278 0 278 0 0 0 556 556
  500 556 556 278 556 556 222 222 500 222 833 556 556 556 556 333 500 278 556 500 722
  500 500 500 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 0
  0 0 0 0 0 0 0 0 0 0 0 0 737 0 556 0 0 737 0 400 0 333 0 0 576 0 0 0 0 0 556 0 0 0
  0 0 0 0 0 667 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 584 0 0 0 0 722 0 0 0 0 0 0 0 556
  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 556 0 0 0 0 0 556 ]
  /Encoding /WinAnsiEncoding
  /FontDescriptor 72 0 R
  >>
  endobj
target_encoding: latin1

EOF
@writer.new_font(font)
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("August 2006.")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_paragraph()
@writer.send_column()
@writer.send_flowing_data("Der Text wurde beh\366rdlich genehmigt und vom verantwortlichen Unternehmen zur Publikation durch die Documed AG")
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("freigegeben.\251 Copyright 2006 by Documed AG, Basel. Die unberechtigte Nutzung und Weitergabe ist untersagt. [22.11.2006]")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_line_break()
@writer.send_column()
@writer.send_flowing_data("Seite 8")
@writer.send_hr()
@writer.send_line_break()
@writer.send_column()
@writer.send_page()
@writer.send_eof()
