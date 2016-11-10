require 'registry/source_record'
require './header'
include Registry

# Extract the item ids from HT's 974s, so we can use them for record updates. 
count = 0
item_count = 0
SourceRecord.where(:org_code => "miaahdl").each do | rec | 
  next if rec.source.nil?
  rec.extract_holdings
  count += 1
  item_count += rec.ht_item_ids.count
  rec.save
end

puts "#{item_count} ids added to #{count} records"

