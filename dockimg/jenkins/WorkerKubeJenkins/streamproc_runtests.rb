#!/home/av.pankratev/.rvm/rubies/ruby-1.9.3-p551/bin/ruby
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

        # create a list of redis
        @queue = Redis::Queue.new('queue_tests', 'tests',  redis: @redis)
        # run tests from posts redis
        @queue.process(true) do |message|
            ex="#{@@opts[:test_tool]} #{message}"
            puts(%x{ #{ex} })
            sleep 1
        end

      end

end
# run programm
if __FILE__ == $0
    data=TrQueue.new
    data.getMessage
end
