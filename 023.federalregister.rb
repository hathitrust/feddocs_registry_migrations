require 'registry_record'
require 'source_record'
require './header' 
require 'pp'

# Add series info to Federal Register source records 

source_count = 0

oclcnums = [1768512,
            3803349,
            9090879,
            6141934,
            27183168,
            9524639,
            60637209,
            25816139,
            27163912,
            7979808,
            4828080,
            18519766,
            41954100,
            43080713,
            38469925,
            97118565,
            70285150 ]



SourceRecord.where(oclc_resolved:{"$in":oclcnums}, series:{"$ne":"FederalRegister"}).no_timeout.each do |src|
  source_count += 1
  src.series = "FederalRegister"
  src.save
end

puts "Source records: #{source_count}"

