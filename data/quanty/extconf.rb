require 'rbconfig'
include Config

target  = 'quanty'
sitedir = File.expand_path('../../src/util', File.dirname(__FILE__))

def install_lib(mfile, dest, dir, files)
  mfile.printf "\t@$(MKDIR) %s/%s\n", dest, dir
  for f in files
    mfile.printf "\t@$(INSTALL) lib/%s/%s %s/%s/%s\n", dir,f, dest,dir,f
  end
end

mfile = open("Makefile", "w")

mfile.print  <<EOMF
SHELL = /bin/sh
RUBY = #{CONFIG["ruby_install_name"]}
RACC = racc
RACCFLAGS = -E
INSTALL = $(RUBY) -r ftools -e 'File::install(ARGV[0], ARGV[1], 0644, true)'
MKDIR   = $(RUBY) -r ftools -e 'File::makedirs(*ARGV)'
RM      = $(RUBY) -r ftools -e 'File::rm_f(*Dir[ARGV.join(" ")])'

sitedir = $(DESTDIR)#{sitedir}

parse = lib/quanty/parse.rb
dump = lib/quanty/units.dump

all: $(parse) $(dump)

$(parse): parse.y
	$(RACC) $(RACCFLAGS) -o $(parse) parse.y

$(dump): units.dat
	$(RUBY) mkdump.rb $(dump)

clean: # $(parse) $(dump)
	@$(RM) $(parse) $(dump)

install: $(sitedir)/quanty/units.dump

site-install: $(sitedir)/quanty/units.dump

$(sitedir)/quanty/units.dump: $(dump)
EOMF

install_lib( mfile, "$(sitedir)", '', ['quanty.rb'] )
install_lib( mfile, "$(sitedir)", 'quanty',
	     %w( main.rb fact.rb parse.rb units.dump ) )
mfile.printf "\n"
