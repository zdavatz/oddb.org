# Ruby/Mock version 1.0
# 
# A class for conveniently building mock objects in RUnit test cases.
# Copyright (c) 2001 Nat Pryce, all rights reserved
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

require 'runit/error'


class Mock
    # Creates a new, named mock object. The name is reported in exceptions
    # thrown by the mock object when method invocations are incorrect.
    # 
    def initialize( mock_name = self.to_s )
        @mock_calls = []
        @next_call = 0
        @name = mock_name
    end
    
    # Mock the next method call to be made to this mock object.
    # 
    # A mock method is defined by the method name (a symbol) and a block
    # that defines the arity of the method and the mocked behaviour for
    # this call.  The mocked behaviour should assert preconditions and
    # return a value.  Mocked behaviour should rarely be any more complex
    # than that.  If it is,  that's probably an indication that the tests
    # need some restructuring or that the tested code needs refactoring.
    # 
    # If no block is given and preconditions have been defined for the named
    # method, a block is created for the mocked methodthat has the same arity
    # as the precondition and returns self.
    # 
    def __next( name, &test )
        if test == nil
            if respond_to?( Mock.__pre(name) )
                test = proc { |*args| self }
            else
                raise "no block given for mocked method #{name}"
            end
        end
        @mock_calls.push( [name,test] )
    end
    
    # Call this at the end of a test to ensure that all scheduled calls
    # have been made to the mock
    #
    def __verify
        if @next_call != @mock_calls.length
            raise RUNIT::AssertionFailedError,
                  "not all expected method calls were made to #{@name}",
                  caller
        end
    end
    
    
private
    # Dispatches aribtrary method calls to the next mocked behaviour
    # 
    def method_missing( name, *args )
        __mock_call( name, args, (block_given? ? proc : nil) )
    end
    
    # Implements a method call using the next mocked behaviour and asserts
    # that the expected method is called with the expected number of 
    # arguments.
    #
    def __mock_call( name, args, block )
        if @next_call >= @mock_calls.length
            raise RUNIT::AssertionFailedError,
                  "unexpected call to #{name} method of #{@name}",
                  caller(2)
        end
        
        expected_name,body = @mock_calls[@next_call]
        @next_call += 1
        
        if name != expected_name
            raise RUNIT::AssertionFailedError,
                  "wrong method called on #{@name}; " +
                      "expected #{expected_name}, was #{name}",
                  caller(2)
        end
        
        args_length = args.length + (block ? 1 : 0)
        
        if body.arity < 0
            if (body.arity+1).abs > args_length 
                raise RUNIT::AssertionFailedError,
                      "too few arguments to #{name} method of #{@name}; " +
                          "require #{(body.arity+1).abs}, got #{args.length}",
                      caller(2)
            end
        else
            if body.arity != args_length
                raise RUNIT::AssertionFailedError,
                      "wrong number of arguments to " +
                          "#{name} method of #{@name}; " +
                          "require #{body.arity}, got #{args.length}",
                      caller(2)
            end
        end
        
        if respond_to? Mock.__pre(name)
            if block
                precondition_ok = __send__( Mock.__pre(name), *args, &block )
            else
                precondition_ok = __send__( Mock.__pre(name), *args )
            end
            
            if not precondition_ok
                raise RUNIT::AssertionFailedError,
                    "precondition of #{name} method violated",
                    caller(2)
            end
        end
        
        if block
            instance_eval { body.call( block, *args ) }
        else
            instance_eval { body.call( *args ) }
        end
    end

    #  The name of a precondition for a method
    def Mock.__pre( method )
        "__pre_#{method.to_i}".intern
    end
    
		
    def Mock.method_added( name )
			unless(/^__pre_/.match(name.to_s))
        pre = self.__pre(name)
        alias_method( pre, name )
        undef_method(name)
			end
    end
end
