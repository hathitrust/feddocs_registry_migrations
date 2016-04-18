require 'registry_record'
require 'source_record'
require './header' 

# There are 500k+ source records with enum_chron "ONLINE" 
# Delete those enum chrons.  
source_count = 0
SourceRecord.where({enum_chrons:"ONLINE"}).no_timeout.each do |r|
  source_count += 1
  r.enum_chrons.delete("ONLINE")
  if r.enum_chrons.count == 0
    r.enum_chrons << ""
  end
  r.save
end
puts "SourceRecords updated: #{source_count}"

