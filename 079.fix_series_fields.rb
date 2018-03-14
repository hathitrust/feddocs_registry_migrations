# My first attempt to make the series fields multivalued was incomplete.
# 066 left behind a lot of series fields with series = "<some string>"
require 'registry/registry_record'
require 'registry/source_record'
require './header'
SourceRecord = Registry::SourceRecord
RegistryRecord = Registry::RegistryRecord

Dotenv.load!

Mongoid.load!(ENV['MONGOID_CONF'], :production)
num_src = 0
SourceRecord.where("series.0":{"$exists":0},
                   series:{"$type":2},
                   deprecated_timestamp:{"$exists":0}).no_timeout.each do |src|
  num_src += 1
  src.series = src.series
  src.save
end 

puts "num src: #{num_src}"
