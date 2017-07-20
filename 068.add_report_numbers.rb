require 'registry/registry_record'
require 'registry/source_record'
require './header'
SourceRecord = Registry::SourceRecord
RegistryRecord = Registry::RegistryRecord

Dotenv.load!

Mongoid.load!(File.expand_path("../config/mongoid.yml", __FILE__), :development)
num_src = 0
SourceRecord.where(deprecated_timestamp:{"$exists":0},
                   "source.fields":{"$elemMatch":{"088":{"$exists":1}}}).no_timeout.each do |src|
  src.report_numbers
  if src.report_numbers.count > 0
    num_src += 1
    src.save
  end
end 

RegistryRecord.where(deprecated_timestamp:{"$exists":0},
                     report_numbers:{"$exists":0}).no_timeout.each do |reg|
  reg.report_numbers
  if reg.report_numbers.count > 0
    num_rr += 1
    reg.save
  end
end

puts "num src: #{num_src}"
puts "num rr:#{num_rr}"
