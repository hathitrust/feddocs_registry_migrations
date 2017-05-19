require 'registry/registry_record'
require 'registry/source_record'
require './header'
SourceRecord = Registry::SourceRecord
RegistryRecord = Registry::RegistryRecord

Dotenv.load!

Mongoid.load!(File.expand_path("../config/mongoid.yml", __FILE__), :development)
num_src = 0
# Extract heading entries 100:110 and  700:710
SourceRecord.where(deprecated_timestamp:{"$exists":0}).no_timeout.each do | src |
  num_src += 1
  src.author_lccns
  src.added_entry_lccns
  src.save
end 

RegistryRecord.where(deprecated_timestamp:{"$exists":0}).no_timeout.each do |reg|
  num_rr += 1
  reg.author_lccns = reg.sources.collect{|s| s.author_lccns}.flatten.uniq
  reg.added_entry_lccns = reg.sources.collect{|s| s.added_entry_lccns}.flatten.uniq
  reg.save
end 

puts "num src records re-extracted: #{num_src}"
puts "num rr:#{num_rr}"
