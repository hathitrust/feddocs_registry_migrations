require 'registry_record'
require 'source_record'
require 'statistical_abstract'
require './header' 
require 'pp'

# Add series info to Statistical Abstract source records 

source_count = 0

oclcnums = StatisticalAbstract.oclcs

SourceRecord.where(oclc_resolved:{"$in":oclcnums}, series:{"$ne":"StatisticalAbstract"}).no_timeout.each do |src|
  source_count += 1
  src.series = "StatisticalAbstract"
  src.save
end

puts "Source records: #{source_count}"

