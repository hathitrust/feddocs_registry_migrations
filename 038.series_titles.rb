require 'registry/registry_record'
require 'registry/source_record'
require 'registry/series/economic_report_of_the_president.rb'
require './header' 
require 'pp'
SourceRecord = Registry::SourceRecord
RegistryRecord = Registry::RegistryRecord
include Registry::Series

# Add series info to source and registry records 
# needless repetition I know

# Economic Report of the President
source_count = 0
rr_count = 0
SourceRecord.where(sudocs:/^#{Regexp.escape(EconomicReportOfThePresident.sudoc_stem)}/).no_timeout.each do |src|
  source_count += 1
  src.series = "EconomicReportOfThePresident"
  src.save
  RegistryRecord.where(source_record_ids:src.source_id, 
                       series:{"$ne":"Economic Report Of The President"}).no_timeout.each do |r|
    r.series = "Economic Report Of The President"
    rr_count += 1
    r.save
  end
end
puts "ERPres sources: #{source_count}"
puts "ERPres RR: #{rr_count}"

source_count = 0
rr_count = 0

#Statistical Abstract
SourceRecord.where(oclc_resolved:{"$in":StatisticalAbstract.oclcs}).no_timeout.each do |src|
  source_count += 1
  src.series = "StatisticalAbstract"
  src.save
  RegistryRecord.where(source_record_ids:src.source_id, 
                       series:{"$ne":"Statistical Abstract"}).no_timeout.each do |r|
    r.series = "Statistical Abstract"
    rr_count += 1
    r.save
  end

end
puts "StatAbs: #{source_count}"
puts "StatABs rr: #{rr_count}"

#United States Reports
SourceRecord.where(oclc_resolved:{"$in":UnitedStatesReports.oclcs}).no_timeout.each do |src|
  source_count += 1
  src.series = "UnitedStatesReports"
  src.save
  RegistryRecord.where(source_record_ids:src.source_id, 
                       series:{"$ne":"United States Reports"}).no_timeout.each do |r|
    r.series = "United States Reports"
    rr_count += 1
    r.save
  end

end
puts "USReports: #{source_count}"
puts "USReports rr: #{rr_count}"

#Foreign Relations of the United States
source_count = 0
rr_count = 0
SourceRecord.where(sudocs:/^#{Regexp.escape(ForeignRelations.sudoc_stem)}/).no_timeout.each do |src|
  source_count += 1
  src.series = "ForeignRelations"
  src.save
  RegistryRecord.where(source_record_ids:src.source_id, 
                       series:{"$ne":"Foreign Relations"}).no_timeout.each do |r|
    r.series = "Foreign Relations"
    rr_count += 1
    r.save
  end

end
puts "FR sources: #{source_count}"
puts "Foreign Relations RR: #{rr_count}"

#Congressional Record
source_count = 0
rr_count = 0
SourceRecord.where(sudocs:/^#{Regexp.escape(CongressionalRecord.sudoc_stem)}/).no_timeout.each do |src|
  source_count += 1
  src.series = "CongressionalRecord"
  src.save
  RegistryRecord.where(source_record_ids:src.source_id, 
                       series:{"$ne":"Congressional Record"}).no_timeout.each do |r|
    r.series = "Congressional Record"
    rr_count += 1
    r.save
  end

end
puts "Congressional Record source: #{source_count}"
puts "congressional Record RR: #{rr_count}"

#Congressional Serial Set
source_count = 0
rr_count = 0
SourceRecord.where(sudocs:/^#{Regexp.escape(CongressionalSerialSet.sudoc_stem)}/).no_timeout.each do |src|
  source_count += 1
  src.series = "CongressionalSerialSet"
  src.save
  RegistryRecord.where(source_record_ids:src.source_id, 
                       series:{"$ne":"Congressional Serial Set"}).no_timeout.each do |r|
    r.series = "Congressional Serial Set"
    rr_count += 1
    r.save
  end
end
puts "Congressional Record source: #{source_count}"
puts "congressional Record RR: #{rr_count}"


