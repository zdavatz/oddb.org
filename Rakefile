# -*- ruby -*-

require 'rubygems'
require 'hoe'
require 'fileutils'

## To run 'rake git:manifest' you will need the 'hoe-git' gem.

Hoe.plugin :git
# Hoe.plugins.delete :clean

# Hoe.plugin :compiler
# Hoe.plugin :cucumberfeatures
# Hoe.plugin :gem_prelude_sucks
# Hoe.plugin :inline
# Hoe.plugin :inline
# Hoe.plugin :manifest
# Hoe.plugin :newgem
# Hoe.plugin :racc
# Hoe.plugin :rubyforge
# Hoe.plugin :rubyforge
# Hoe.plugin :website

Hoe.spec 'oddb.org' do
  # HEY! If you fill these out in ~/.hoe_template/Rakefile.erb then
  # you'll never have to touch them again!
  # (delete this comment too, of course)

developer('Masaomi Hatakeyama, Zeno R.R. Davatz', 'mhatakeyama@ywesee.com, zdavatz@ywesee.com')
self.local_rdoc_dir = 'rdoc'

  # self.rubyforge_name = 'oddb.orgx' # if different than 'oddb.org'
end

desc 'Build quanty'
task :quanty do
  unless File.exists?(File.join(File.dirname(__FILE__), 'src/util/quanty/parse.rb'))
    FileUtils.makedirs(File.join(File.dirname(__FILE__), 'data/pdf'))
    Dir.chdir(File.join(File.dirname(__FILE__), 'data/quanty'))
    exit 2 unless system('ruby extconf.rb')
    src='parse.y'
    dst='lib/quanty/parse.rb'
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

task :test => :quanty
# vim: syntax=ruby
