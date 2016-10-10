#!/usr/bin/ruby
# coding: utf-8

require 'rubygems'
require 'redis'
require 'redis-queue'
require 'trollop'

class TrQueue

      @@opts = Trollop::options do
        banner <<-EOS

      It handles all redis:

      it is very important to use the need to:
            streamproc_runtests.rb [options]
      To run this module you need to use a parameters:
      :redis_host, :redis_port, :test_tool
      where [options] are:
      EOS
        opt :test_tool, "tool for testing, example: rspec", :type => :string
        opt :redis_host, "redis hostname", :type => :string
        opt :redis_port, "redis port", :type => :integer
      end

      # check option
      Trollop::die "Need fill parameter :redis_host and :redis_port! See create_redis_queue.rb -h" unless  @@opts[:test_tool] && @@opts[:redis_host] &&  @@opts[:redis_port]

      # initialize a variable

      def initializes
      	@flproject="testResult.txt"
      end

      # method connect to redis server
      def conRed
        begin
            puts "Connecting to Redis..."
            @redis = Redis.new( host: @@opts[:redis_host].chomp, port: @@opts[:redis_port])
            @redis.ping
        rescue Errno::ECONNREFUSED => e
            puts "Error: Redis server unavailable. Shutting down..."
            e.message
            e.inspect
            exit 1
        end
      end

      def getMessage

        # connect to redis
        conRed
        # prepare project
        %x{ /etc/init.d/postgresql start }
        %x{ bundle install }
	%x{ bundle exec rake db:setup }
        %x{ bundle exec rake db:test:prepare }
        # create a list of redis
        @queue = Redis::Queue.new('queue_tests', 'tests',  redis: @redis)
        # run tests from posts redis
        @queue.process(true) do |message|
            ex="#{@@opts[:test_tool]} #{message}"
            File.open(@flproject, 'a') do |f|
                tres=%x{ #{ex} } 
            	f.write( puts(tres) )
            end            
        end

      end

end
# run programm
if __FILE__ == $0
    data=TrQueue.new
    data.getMessage
end

