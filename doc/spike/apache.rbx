#!/usr/bin/env ruby

(Apache.public_methods-Object.public_methods).sort.each { |m|
	p m
	p Apache.method(m).arity == 0 ? Apache.send(m) : ''
}

p '--------------------------------------------------------------------------'

request = Apache.request.connection
(request.public_methods-Object.new.public_methods).sort.each { |m|
	p m
	p request.method(m).arity == 0 ? request.send(m) : ''
}
