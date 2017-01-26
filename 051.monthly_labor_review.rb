require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry
include Registry::Series
# Parse enumchrons for Monthly Labor Review registry records 
#
deprecate_count = 0
source_count = 0
rr_count = 0

=begin
=end
#Monthly Labor Reports
source_count = 0
rr_count = 0
SourceRecord.where(oclc_resolved:{"$in":MonthlyLaborReport.oclcs).no_timeout.each do |src|
  source_count += 1
  src.series = "MonthlyLaborReport"
  src.save
  RegistryRecord.where(source_record_ids:src.source_id, 
                       series:{"$ne":"Monthly Labor Report"}).no_timeout.each do |r|
    r.series = "Monthly Labor Report"
    rr_count += 1
    r.save
  end
end
puts "MLR sources: #{source_count}"

# Re-extract all the Source Records
SourceRecord.where(series: "MonthlyLaborReport",
                   deprecated_timestamp:{"$exists":0}).no_timeout.each do |src|
  source_count += 1

  # wth flasus?
  if src.org_code == 'flasus'
    f = src.source['fields'].find {|f| f['955'] }['955']['subfields']
    v = f.select { |h| h['v'] }[0]
    junk_sf = f.select { |h| h.keys[0] =~ /\./ }[0]
    if !junk_sf.nil?
      junk = junk_sf.keys[0]
      v['v'] = junk
      f.delete_if { |h| h.keys[0] =~ /\./ }
    end
  end

  src.source = src.source.to_json #re-extraction done here
  res = src.update_in_registry #this will take care of everything
  deprecate_count += res[:num_deleted]
  rr_count += res[:num_new]
  src.save
end

puts "# new RegRecs: #{rr_count}"
puts "Deprecated records: #{deprecate_count}"
puts "Source records: #{source_count}"
