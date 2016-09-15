require 'source_record'
require './header'

# Extract the id from miu's 001s, so we can use them for record updates. 
count = 0
SourceRecord.where(:org_code => "miu").each do | rec | 
  #we'll remove leading zeroes
  rec.local_id = rec.extract_local_id.gsub(/^0*/, '')
  rec.save
  count += 1
end

puts "miu Ids added to #{count}"



