require 'registry/registry_record'
require 'registry/source_record'
require './header'
SourceRecord = Registry::SourceRecord
RegistryRecord = Registry::RegistryRecord

Dotenv.load!

Mongoid.load!(File.expand_path("../config/mongoid.yml", __FILE__), :development)

# Some records, mostly miu and miaahdl, had "II0 a" prepended to their 086s. 
#
num_src = 0
num_rr = 0

RegistryRecord.where(sudoc_display:/^II0 +a/,
                     deprecated_timestamp:{"$exists":0}).no_timeout.each do | rr |
  num_rr += 1
  rr.sudoc_display = rr.sudoc_display.map { |s| s.sub(/^II0 +a/, '') }
  rr.save
end

SourceRecord.where(sudocs:/^II0 +a/,
                   deprecated_timestamp:{"$exists":0}).no_timeout.each do | src |
  num_src += 1
  begin
    src.sudocs = src.extract_sudocs
    src.save
  rescue
    PP.pp src.source.to_json
    next
  end
end

puts "num src records re-extracted: #{num_src}"
puts "num rr dep:#{num_rr}"
