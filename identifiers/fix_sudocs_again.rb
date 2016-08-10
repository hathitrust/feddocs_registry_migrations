require 'registry_record'
require 'source_record'
require_relative '../header' 

num_old_sudocs = 0
num_non_sudocs = 0
num_invalid_sudocs = 0
num_fixed = 0
SourceRecord.where(deprecated_timestamp:{"$exists":0}, "non_sudocs.0":{"$exists":1}).no_timeout.each do |r|
  old_sudocs = r.sudocs
  num_old_sudocs += old_sudocs.count

  r.extract_sudocs
  num_non_sudocs += r.non_sudocs.count
  num_invalid_sudocs += r.invalid_sudocs.count
  num_fixed += (old_sudocs & r.non_sudocs).count
  r.save
end
puts "num old sudocs: #{num_old_sudocs}"
puts "num non sudocs: #{num_non_sudocs}"
puts "num invalid sudocs: #{num_invalid_sudocs}"
puts "num sudocs to be fixed: #{num_fixed}"
