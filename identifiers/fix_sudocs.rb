#this doesn't need to be repeated. 
#We weren't checking for ind1 == 0 for sudocs

require 'registry_record'
require 'source_record'
require_relative '../header' 
require 'pp'
require 'mongo'
require 'dotenv'
require 'library_stdnums'

Dotenv.load

Mongoid.load!("config/mongoid.yml", :development)
Mongo::Logger.logger.level = ::Logger::FATAL

@mc = Mongo::Client.new([ENV['mongo_host']+':'+ENV['mongo_port']], :database => 'htgd' )
count = 0
SourceRecord.all.each do | rec |
  count += 1

  rec.extract_sudocs 
  rec.save

  if count % 10000 == 0 
    print "#{count}\r"
    $stdout.flush
  end

end #each rec
