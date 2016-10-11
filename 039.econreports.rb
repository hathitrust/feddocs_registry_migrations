require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry
include Registry::Series
# Parse enumchrons for Economic Report registry records 

deprecate_count = 0
source_count = 0
rr_count = 0

# Deprecate all the EconReport RegRecs and start again with SourceRecords
RegistryRecord.where(series:"Econcomic Report Of The President",
                     deprecated_timestamp:{"$exists":0}).no_timeout.each do |reg|
  reg.deprecate('Improved Economic Report enum/chron parsing.')
  deprecate_count += 1
end

# Re-extract all the Source Records
SourceRecord.where(series: "EconomicReportOfThePresident",
                   deprecated_timestamp:{"$exists":0}).no_timeout.each do |src|
  source_count += 1
  src.source = src.source.to_json
  src.enum_chrons.each do | ec | 
    rr_count += 1
    if regrec = RegistryRecord::cluster( src, ec)
      regrec.add_source(src)
    else
      regrec = RegistryRecord.new([src.source_id], ec, "Improved Econ Report enum/chron parsing.")
    end
    regrec.save
  end
  src.save

end

puts "# new RegRecs: #{rr_count}"
puts "Deprecated records: #{deprecate_count}"
puts "Source records: #{source_count}"

