#!/home/av.pankratev/.rvm/rubies/ruby-1.9.3-p551/bin/ruby
# coding: utf-8

require 'rubygems'
require 'redis'
require 'redis-queue'
require 'json'
require 'yaml'
require 'trollop'

@@opts = Trollop::options do
  banner <<-EOS

It creates a redis in all tests to perform in Kubernetes :

it is very important to use the need to:
      create_redis_queue.rb [options]
To create a queue with the tests you need to use a single parameter: :fnumber
where [options] are:
EOS
  opt :fnumber, "with the number of test files to run in a single container", :type => :string
end

class CrQueue

      def initialize
        @redis = Redis.new( host: "localhost", port: 6379)
      end

      def createQueue
        Trollop::die "Need fill parameter :fnamber! See create_redis_queue.rb -h" unless @@opts[:fnumber]
        queue = Redis::Queue.new('queue_tests', 'bp_q_test',  redis: @redis)
        queue.push "filesone.rspec, filestwo.rb"
      end

end

if __FILE__ == $0
    data=CrQueue.new
    data.createQueue
end
