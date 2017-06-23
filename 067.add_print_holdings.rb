require 'registry/registry_record'
require 'registry/source_record'
require './header'
SourceRecord = Registry::SourceRecord
RegistryRecord = Registry::RegistryRecord

Dotenv.load!

Mongoid.load!(File.expand_path("../config/mongoid.yml", __FILE__), :development)
num_rr = 0
RegistryRecord.where(deprecated_timestamp:{"$exists":0},
                     print_holdings_t:{"$exists":0}).no_timeout.each do |reg|
  num_rr += 1
  reg.print_holdings
  reg.save
end 

puts "num rr:#{num_rr}"
