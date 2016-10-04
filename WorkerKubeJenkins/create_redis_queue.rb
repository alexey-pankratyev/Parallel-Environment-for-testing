#!/home/av.pankratev/.rvm/rubies/ruby-1.9.3-p551/bin/ruby
# coding: utf-8

require 'rubygems'
require 'redis'
require 'redis-queue'
require 'trollop'
require 'find'

class CrQueue

      @@opts = Trollop::options do
        banner <<-EOS

      It creates a redis in all tests to perform in Kubernetes :

      it is very important to use the need to:
            create_redis_queue.rb [options]
      To create a queue with the tests you need to use a parameters: :fnumber, :pathtest and :pattern
      where [options] are:
      EOS
        opt :fnumber, "with the number of test files to run in a single container", :type => :integer
        opt :pathtest, "path to files test in project", :type => :string
        opt :pattern, "file search pattern", :type => :string
      end

      # check option
      Trollop::die "Need fill parameter :fnamber, :pathtest, :pattern ! See create_redis_queue.rb -h" unless @@opts[:pathtest] && @@opts[:pattern] && @@opts[:fnumber]


      # initialize a variable for the connection of redis
      def initializes
      end

      # method connect to redis server
      def conRed
        begin
            puts "Connecting to Redis..."
            @redis = Redis.new( host: "localhost", port: 6379)
            @redis.ping
        rescue Errno::ECONNREFUSED => e
            puts "Error: Redis server unavailable. Shutting down..."
            e.message
            e.inspect
            exit 1
        end
      end

      # generate a list of test files
      def listFt
        dt=[]
        pattern=@@opts[:pattern].chomp
        Find.find(@@opts[:pathtest].chomp) do |path|
          if FileTest.directory?(path)
            if File.basename(path)[0] == ?.
              Find.prune       # This catalog does not seek more.
            else
              next
            end
          else
            if File.fnmatch(pattern,File.basename(path))
              dt << File.absolute_path(path)
            end
          end
        end
        return dt
     end

      def createQueue

        # check if available redis and check that there are test files
        begin
            raise RuntimeError, 'No of files for checking' if  listFt.empty?
        rescue Exception => e
        # O error if something goes wrong
            e.message
            p e.inspect
            exit 1
        end

        # connect to redis
        conRed

        # create a list of radis
        queue = Redis::Queue.new('queue_tests', 'tests',  redis: @redis)
        # delete old list queue_tests
        queue.clear true
        # write our test files in it
        listFt.each_slice(@@opts[:fnumber]) do |s|
          queue << s.to_s
        end

      end

end

if __FILE__ == $0
    data=CrQueue.new
    data.createQueue
end
