require 'rubygems'
require 'hoe'
require 'fileutils'
require 'rake/clean'

## To run 'rake git:manifest' you will need the 'hoe-git' gem.

Hoe.plugin :git
Hoe.plugin :travis

Hoe.spec 'oddb.org' do
  # HEY! If you fill these out in ~/.hoe_template/Rakefile.erb then
  # you'll never have to touch them again!
  # (delete this comment too, of course)

developer('Masaomi Hatakeyama, Zeno R.R. Davatz, Niklaus Giger', 'mhatakeyama@ywesee.com, zdavatz@ywesee.com, ngiger@ywesee.co')
self.local_rdoc_dir = 'rdoc'

end

class Rake::Task
  def overwrite(&block)
    @actions.clear
    enhance(&block)
  end
end

desc 'Build quanty'
task :quanty do
  parse_rb_name = File.join(File.dirname(__FILE__), 'src/util/quanty/parse.rb')
  unless File.exists?(parse_rb_name)
    FileUtils.makedirs(File.join(File.dirname(__FILE__), 'data/pdf'))
    Dir.chdir(File.join(File.dirname(__FILE__), 'data/quanty'))
    exit 2 unless system('ruby extconf.rb')
    src='parse.y'
    dst=parse_rb_name
    tmp='lib/quanty/parse.backup'
    FileUtils.rm_f(dst)
    FileUtils.makedirs(File.dirname(dst))
    cmd = "ruby `which racc` -E -o #{dst} #{src}"
    exit 2 unless system(cmd)
    inhalt = IO.read(dst)
    ausgabe = "# encoding: utf-8\n"+inhalt
    aus = File.open(dst, 'w+')
    aus.puts(ausgabe)
    aus.close
    exit 2 unless system("make")
    exit 2 unless system("make install")
  end
end 

Rake::Task[:docs].overwrite do
  FileUtils.rm_rf('documentation', :verbose => true)
  system("rdoc --main README.txt --format=darkfish --exclude 'js' --exclude 'Gemfile*' --exclude 'sql.in' --exclude 'csv' --exclude 'bak' --exclude 'coverage' --exclude 'log' --exclude 'xml' --exclude 'yaml' --exclude 'yml' --exclude 'patch' --exclude '~' --exclude 'html' --exclude 'test'  --exclude 'data' --exclude 'pdf' --exclude 'vendor' --op documentation/")
end

Rake::Task[:test].overwrite do
  puts "Instead of calling Rake::Test we call test/suite.rb"
  cov = File.expand_path(File.join(File.dirname(__FILE__), 'coverage'))
  FileUtils.rm_rf(cov, :verbose => true)
	res = system(File.join(File.dirname(__FILE__), 'test', 'suite.rb'))
	puts "Calling from rake test/suite.rb returned #{res.inspect}"
  exit(4) unless res
end

task :test => :quanty
CLEAN.include('*.yaml')
CLEAN.include('*.html')
# vim: syntax=ruby
