require 'registry/registry_record'
require 'registry/source_record'
require './header'
SourceRecord = Registry::SourceRecord
RegistryRecord = Registry::RegistryRecord

Dotenv.load!

Mongoid.load!(File.expand_path("../config/mongoid.yml", __FILE__), :development)
num_src = 0
SourceRecord.where(deprecated_timestamp:{"$exists":0}).no_timeout.each do |src|
  num_src += 1
  if src.series.nil?
    src.series = []
  else
    src.series = [src.series].flatten
  end
  src.save
end 

num_rr = 0
RegistryRecord.where(deprecated_timestamp:{"$exists":0}).no_timeout.each do |reg|
  num_rr += 1
  if reg.series.nil?
    reg.series = []
  else
    reg.series = [reg.series].flatten
  end
  reg.save
end

puts "num src: #{num_src}"
puts "num rr:#{num_rr}"
