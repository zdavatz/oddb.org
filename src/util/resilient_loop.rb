#!/usr/bin/env ruby
# encoding: utf-8

require 'util/logfile'
require 'timeout'

module ODDB
  #
  # ResilientLoop is a helper class for running long lasting jobs like imports
  # It has the following characterstics
  # * Possible to restart a failed job at the failing id
  # * Retry an import after a timeout (e.g. of 10 seconds) 
  #
  # -------------
  # requirements:
  # -------------
  # Needed is state-id (e.g. an EAN13 code) which allows to distingish whether
  # a loop item was already processed or not
  #
  # ---------------
  # implementation:
  # ---------------
  # the state is saved in a text file
  # 
  ExampleUsage = %(
      r_loop = ResilientLoop.new(LoopName)
      loop_entries.each{
        |entry|
          next if r_loop.must_skip?(entry)
          r_loop.try_run(entry, TimeoutValue) { /* do your work */ }
      }
      r_loop.finished
)
  class ResilientLoop
    attr_reader :state_file, :nr_skipped, :state_id
    attr_writer :nr_retries
    
    def initialize(loopname, state_id = nil)
      @mutex = Mutex.new
      @loopname   = loopname
      @state_id   = state_id
      @nr_skipped = 0
      @nr_retries = 3
      get_state
    end

    def must_skip?(id)
      return false unless @state_id
      if id
        clear_state if id.to_s.eql?(@state_id.to_s)
        @nr_skipped += 1
        return true
      else
        return false
      end
    end

    def try_run(state, timeout_in_secs = 10, &block)
      idx = 0
      while true
        @mutex.synchronize do
          idx < @nr_retries
          idx += 1
        end
        begin
          status = Timeout.timeout(timeout_in_secs) do
            block.call
            save_state(state)
            return
          end
        rescue Timeout::Error
          raise Timeout::Error if @nr_retries == idx
        end
      end
    end

    def finished
      clear_state
    end
private 
    def get_state
      @state_file = File.join(ODDB::LogFile::LOG_ROOT, @loopname + '.state')
      if File.exist?(@state_file)
        content = IO.read(@state_file)
        eval("@state_id = #{content}")
      else
        @state_id = nil
      end
    end
    def save_state(state)
      @mutex.synchronize do
        FileUtils.mkdir_p File.dirname(@state_file)
        File.open(@state_file, 'w+') { |f| f.write(state)}
      end
    end
    def clear_state
      @mutex.synchronize do
        @state_id = nil
        FileUtils.rm_f(@state_file)
      end
    end
  end
end
