require 'registry/registry_record'
require 'registry/source_record'
require './header'
SourceRecord = Registry::SourceRecord
RegistryRecord = Registry::RegistryRecord

Dotenv.load!

Mongoid.load!(File.expand_path("../config/mongoid.yml", __FILE__), :development)
num_src = 0
SourceRecord.where(series:{"$ne":[]},
                   deprecated_timestamp:{"$exists":0}).no_timeout.each do |src|
  num_src += 1
  src.series = src.series
  src.save
end 

num_rr = 0
RegistryRecord.where("$and":[{series:{"$exists":1}},
                             {series:{"$ne":[]}}],
                     deprecated_timestamp:{"$exists":0}).no_timeout.each do |reg|
  num_rr += 1
  reg.series = reg.series
  reg.save
end

puts "num src: #{num_src}"
puts "num rr:#{num_rr}"
