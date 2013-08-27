require 'rubygems'
require 'hoe'
require 'fileutils'

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

Rake::Task[:docs].overwrite do
  FileUtils.rm_rf('documentation', :verbose => true)
  system("rdoc --format=darkfish --exclude 'xml' --exclude 'yaml' --exclude 'yml' --exclude 'patch' --exclude '~' --exclude 'html' --exclude 'test'  --exclude 'data' --exclude 'pdf' --exclude 'vendor' --op documentation/")
end

Rake::Task[:test].overwrite do
  puts "Instead of calling Rake::Test we call test/suite.rb"
  exit(1) unless system(File.join(File.dirname(__FILE__), 'test', 'suite.rb'))
end

# vim: syntax=ruby
