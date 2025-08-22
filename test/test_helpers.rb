ENV["TZ"] = "UTC"

require "vcr"
require "webmock"
require "fileutils"
require "zip"
require "flexmock"
$: << File.expand_path("../src", File.dirname(__FILE__))
require "util/workdir"

begin require "debug"; rescue LoadError; end # ignore error when debug cannot be loaded (for Jenkins-CI)

module ODDB
  module TestHelpers
    # Zips input_filenames (using the basename)
    def self.zip_files(zipfile_name, input_filenames)
      FileUtils.rm_f(zipfile_name)
      Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
        input_filenames.each do |filename|
          puts "Add #{filename} #{File.size(filename)} bytes as #{File.basename(filename)} #{Dir.pwd}" if $VERBOSE
          zipfile.add(File.basename(filename), filename)
        end
      end
    end

    # Unzips into a specific directory
    def self.unzip_files(zipfile_name, directory)
      savedDir = Dir.pwd
      FileUtils.makedirs(directory)
      Dir.chdir(directory)
      Zip::File.open(zipfile_name) do |zip_file|
        # Handle entries one by one
        zip_file.each do |entry|
          # Extract to file/directory/symlink
          puts "Extracting #{entry.name} into #{directory}"
          FileUtils.rm_f(File.join(directory, entry.name))
          entry.extract(entry.name)
        end
      end
    ensure
      Dir.chdir(savedDir)
    end
    LEVETIRACETAM_GTIN = 7680620690084
    LEVETIRACETAM_PHAR = 5819012
    LEVETIRACETAM_NAME_DE = "LEVETIRACETAM DESITIN Mini Filmtab 250 mg 30 Stk"
    GTINS_CALC = [
      "7680458820202", # for calc_spec.rb
      "7680555940018", # for calc_spec.rb
      "7680434541015", # for calc_spec.rb
      "7680300150105", # for calc_spec.rb
      "7680446250592", # for calc_spec.rb
      "7680611860045", # for calc_spec.rb
      "7680165980114", # for calc_spec.rb
      "7680589430011", # for calc_spec.rb
      "7680556740075", # for calc_spec.rb
      "7680540151009", # for calc_spec.rb
      "7680560890018" # for calc_spec.rb
    ]
    GTINS_DRUGS = ["733905577161", # 1-DAY ACUVUE Moist Tag -2.00dpt BC 8.5
      "4042809018288",
      "4042809018400",
      "4042809018493",
      "5000223074777",
      "5000223439507",
      "7611600441013",
      "7611600441020",
      "7611600441037",
      "7680161050583", # Hirudoid Creme 3 mg/g
      "7680172330414", # SELSUN
      "7680284860144",
      "7680316440115", # FERRO-GRADUMET Depottabl 30 Stk
      "7680316950157", # SOFRADEX Gtt Auric 8 ml
      "7680324750190", # LANSOYL Gel
      "7680353660163",
      "7680403330459",
      "7680536620137", # 3TC Filmtabl 150 mg
      "7680555580054", # ZYVOXID
      "7680620690084" # LEVETIRACETAM DESITIN Mini Filmtab 250 mg needed for extractor_spec.rb
] + GTINS_CALC

    def self.vcr_setup
      VCR.eject_cassette
      VCR.configure do |c|
        c.hook_into :webmock
        c.preserve_exact_body_bytes do |http_message|
          http_message.body.encoding.name == "ASCII-8BIT" ||
            !http_message.body.valid_encoding?
        end
        c.cassette_library_dir = File.expand_path("#{Dir.pwd}/fixtures/vcr_cassettes")
        c.before_record(:lppv) do |i|
          if /LPPV_D/ =~ i.request.uri
            dummy = File.join(ODDB::TEST_DATA_DIR, "lppv", "LPPV_D.xlsx")
            i.response.body = IO.read(dummy)
            i.response.headers["Content-Length"] = i.response.body.size
            puts "#{Time.now}: #{__LINE__}: URI was #{i.request.uri} replacing by #{dummy}"
          end
        end
        c.before_record(:Refdata_Article) do |i|
          if /zurrose/i =~ i.request.uri
            puts "#{Time.now}: #{__LINE__}: URI was #{i.request.uri}"
            lines = i.response.body.clone.split("\n")
            to_add = lines[0..5]
            TestHelpers::GTINS_DRUGS.each { |ean| to_add << lines.find { |x| x.index(ean.to_s) } }
            i.response.body = to_add.compact.join("\n")
            i.response.headers["Content-Length"] = i.response.body.size
          end
          if /epha/ =~ i.request.uri
            puts "#{Time.now}: #{__LINE__}: URI was #{i.request.uri}"
            lines = i.response.body.split("\n")
            to_add = lines[0..5]
            iksnrs = []
 TestHelpers::GTINS_DRUGS.each { |x| iksnrs << x[4..9] }
            iksnrs.each { |iksnr| to_add << lines.find { |x| x.index("," + iksnr.to_s + ",") } }
            i.response.body = to_add.compact.join("\n")
            i.response.body = i.response.body.split("\n")[0..5].join("\n")
            i.response.headers["Content-Length"] = i.response.body.size
          end
          if i.response.headers["Content-Disposition"] and /www.swissmedic.ch/.match(i.request.uri)
            puts "#{Time.now}: URI was #{i.request.uri}"
            m = /filename=.([^\d]+)/.match(i.response.headers["Content-Disposition"][0])
            if m and true
              puts "#{Time.now}: SwissmedicDownloader #{m[1]} (#{i.response.body.size} bytes)."
              name = m[1].chomp("_")
              swissmedic_dir = File.join(ODDB::TEST_DATA_DIR, "swissmedic")
              FileUtils.makedirs(swissmedic_dir)
              xlsx_name = File.join(swissmedic_dir, name + ".xlsx")
              if /Packungen/i =~ xlsx_name
                File.open(xlsx_name, "wb+") { |f| f.write(i.response.body) }
                puts "#{Time.now}: Openening saved #{xlsx_name} (#{File.size(xlsx_name)} bytes) will take some time. URI was #{i.request.uri}"
                workbook = RubyXL::Parser.parse(xlsx_name)
                worksheet = workbook[0]
                drugs = []
                TestHelpers::GTINS_DRUGS.each { |x| next unless x.to_s.size == 13
 drugs << [x.to_s[4..8].to_i, x.to_s[9..11].to_i] }
                idx = 6
 to_delete = []
                puts "#{Time.now}: Finding items to delete will take some time"
                while worksheet.sheet_data[idx]
                  idx += 1
                  next unless worksheet.sheet_data[idx - 1][0]
                  to_delete << (idx - 1) unless drugs.find { |x| 
                                                x[0] == worksheet.sheet_data[idx - 1][0].value.to_i and
                    x[1] == worksheet.sheet_data[idx - 1][10].value.to_i
                  }
                end
                if to_delete.size > 0
                  puts "#{Time.now}: Deleting #{to_delete.size} of the #{idx} items will take some time"
                  to_delete.reverse_each { |row_id| worksheet.delete_row(row_id) }
                  workbook.write(xlsx_name)
                  i.response.body = IO.binread(xlsx_name)
                  i.response.headers["Content-Length"] = i.response.body.size
                  puts "#{Time.now}: response.body is now #{i.response.body.size} bytes long. #{xlsx_name} was #{File.size(xlsx_name)}"
                end
              end
            end
          end
          if i.response.headers["Content-Disposition"] and /XMLPublications.zip/.match(i.request.uri)
            bag_dir = File.join(ODDB::TEST_DATA_DIR, "bag")
            FileUtils.makedirs(ODDB::TEST_DATA_DIR)
            tmp_zip = File.join(ODDB::TEST_DATA_DIR, "XMLPublications.zip")
            File.open(tmp_zip, "wb+") { |f| f.write(i.response.body) }
            TestHelpers.unzip_files(tmp_zip, bag_dir)
            bag_tmp = File.join(bag_dir, "Preparations.xml")
            puts "#{Time.now}: #{__LINE__}: Parsing #{File.size(bag_tmp)} (#{File.size(bag_tmp)} bytes) will take some time. URI was #{i.request.uri}"
            doc = REXML::Document.new(File.read(bag_tmp))
            items = doc.root.elements
            puts "#{Time.now}: Removing most of the #{items.size} items will take some time"
            items.each { |x| items.delete x unless TestHelpers::GTINS_DRUGS.index(x.elements["Packs/Pack/GTIN"].text) }
            File.open(bag_tmp, "wb+") { |f| f.write(doc.to_s.gsub(/\n\s+\n/, "\n")) }
            puts "Saved #{bag_tmp} (#{File.size(tmp_zip)} bytes)"
            TestHelpers.zip_files(tmp_zip, Dir.glob("#{bag_dir}/*"))
            puts "Saved #{tmp_zip} (#{File.size(tmp_zip)} bytes)"
            i.response.body = IO.binread(tmp_zip)
            i.response.headers["Content-Length"] = i.response.body.size
            puts "#{Time.now}: response.body is now #{i.response.body.size} bytes long. #{tmp_zip} was #{File.size(tmp_zip)}"
          end
          if !/WSDL$/.match(i.request.uri)() and /refdatabase.refdata.ch\/Service/.match(i.request.uri)
            puts "#{Time.now}: #{__LINE__}: Parsing response.body (#{i.response.body.size} bytes) will take some time. URI was #{i.request.uri}"
            doc = REXML::Document.new(i.response.body)
            items = doc.root.children.first.elements.first
            nrItems = doc.root.children.first.elements.first.elements.size
            puts "#{Time.now}: #{__LINE__}: Removing most of the #{nrItems} items will take some time"
            nrSearched = 0
            items.elements.each { |x|
              next if x.elements["OK_ERROR"]
              nrSearched += 1
              puts "#{Time.now}: #{__LINE__}: nrSearched #{nrSearched}/#{nrItems}" if nrSearched % 1000 == 0
              items.delete x unless x.elements["GTIN"] and GTINS_DRUGS.index(x.elements["GTIN"].text)
            }
            i.response.body = doc.to_s
            puts "#{Time.now}: response.body is now #{i.response.body.size} bytes long"
            i.response.headers["Content-Length"] = i.response.body.size
          end
        end
      end
      VCR.insert_cassette("oddb2xml",
        tag: :Refdata_Article,
        record: :new_episodes,
        serialize_with: :json,
        match_requests_on: [:method, :uri, :body],
        preserve_exact_body_bytes: true)
    end

    def self.vcr_teardown
      VCR.eject_cassette
    end
  end
end
include WebMock::API

def mock_downloads
  WebMock.enable!
  {"https://www.swissmedic.ch/swissmedic/de/home/services/listen_neu.html" => "html/listen_neu.html",
    "https://www.swissmedic.ch/dam/swissmedic/de/dokumente/internetlisten/erweiterte_ham.xlsx.download.xlsx/Erweiterte_Arzneimittelliste%20HAM_31012019.xlsx" =>
      "xlsx/Erweiterte_Arzneimittelliste_HAM_31012019.xlsx",
    "https://www.swissmedic.ch/dam/swissmedic/de/dokumente/internetlisten/zugelassene_packungen_human.xlsx.download.xlsx/zugelassene_packungen_ham.xlsx" => "xlsx/Erweiterte_Arzneimittelliste_HAM_31012019.xlsx",
    /https:\/\/www.swissmedic.ch\/dam\/swissmedic.*zugelassene_packungen_ham.xlsx.*/ => "xlsx/Erweiterte_Arzneimittelliste_HAM_31012019.xlsx"}.each do |url, file|
    inhalt = File.read(File.join(Dir.pwd, "test", "data", file))
    m = flexmock("open-uri")
    if defined?(@plugin)
      @plugin.should_receive(:fetch_with_http).and_return(inhalt)
    end
    m.should_receive(:open).with(url).and_return(inhalt)
    stub_request(:any, url).to_return(body: inhalt)
    stub_request(:get, url).to_return(body: inhalt)
    stub_request(:open, url).to_return(body: inhalt)
  end
end
