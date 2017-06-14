require 'registry/registry_record'
require 'registry/source_record'
require './header'
SourceRecord = Registry::SourceRecord
RegistryRecord = Registry::RegistryRecord

Dotenv.load!

Mongoid.load!(File.expand_path("../config/mongoid.yml", __FILE__), :development)
num_src = 0
SourceRecord.where(deprecated_timestamp:{"$exists":0},
          		     oclc_resolved:{"$in":[1064763, 36542869, 173847259, 21986096]}).no_timeout.each do | src |
  num_src += 1
  src.source = src.source.to_json
  src.save
  src.ec.each do | k, ec | 
    puts ec['string']
  end
end 
puts "num src records re-extracted: #{num_src}"
