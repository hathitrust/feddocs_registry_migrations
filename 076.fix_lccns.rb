require 'registry/registry_record'
require 'registry/source_record'
require './header'
SourceRecord = Registry::SourceRecord
RegistryRecord = Registry::RegistryRecord

# 10k Source Records have author_lccn fields instead of author_lccns.
# 112434 Registry Records have subject headings in their author_lccn fields instead of name authorities.
#
Dotenv.load!

Mongoid.load!(File.expand_path("../config/mongoid.yml", __FILE__), :development)
num_src = 0
# Extract heading entries 100:110 and  700:710
SourceRecord.where(author_lccn:{"$exists":1},
                   deprecated_timestamp:{"$exists":0}).no_timeout.each do | src |
  src.author_lccns
  src.added_entry_lccns
  src.unset(:author_lccn)
  src.save
  num_src += 1
end 

num_rr = 0
RegistryRecord.where("$or":[
                        {author_lccns:/lccn.loc.gov\/sh/},
                        {added_entry_lccns:/lccn.loc.gov\/sh/}],
                        deprecated_timestamp:{"$exists":0}).no_timeout.each do |reg|
  num_rr += 1
  reg.author_lccns = reg.sources.collect{|s| s.author_lccns}.flatten.uniq
  reg.added_entry_lccns = reg.sources.collect{|s| s.added_entry_lccns}.flatten.uniq
  reg.save
end 

puts "num src records re-extracted: #{num_src}"
puts "num rr:#{num_rr}"
