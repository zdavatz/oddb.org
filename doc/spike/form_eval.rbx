#!/usr/bin/env ruby

request = CGI.new("html4Tr")

#p request.params

request.params.each { |key, val|
	puts key
	val = val.pop
	puts val
	puts val.class
	puts val.original_filename
	begin
		puts Marshal.dump(val)
	rescue Exception => e
		puts e
	end
	#puts (val.methods - Object.new.methods).sort.join("\n")
	#	p val.collect { |io| p io; p lines = io.readlines; lines }
	p "=============="
}

#p request.params["fileupload"].class
#p request["fileupload"].first.class

#request["fileupload"].first.each { |line|
	#p line
	#}
