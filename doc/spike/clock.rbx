#!/usr/bin/env ruby
# clock.rb
require 'drb/drb'

class Clock
    include DRbUndumped
    def initialize(ticker)
        @ticker = ticker
        @ticker.add_observer(self)
    end

    def update(time)
        p time
    end

    def done
        begin
            @ticker.delete_observer(self)
        rescue
        end
    end
end

DRb.start_service
ticker = DRbObject.new(nil, "druby://localhost:7640")
clock = Clock.new(ticker)
sleep 2
clock.done
