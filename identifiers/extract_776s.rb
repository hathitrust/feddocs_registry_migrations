require 'registry_record'
require 'source_record'
require './header' 

# Find source recs with 776. Re-extract their identifiers. If they changed, 
# recollate. 
#
# We will cluster sources with 776 identifiers in 015.cluster.rb and
# dedupe registry records in 016.merge.rb 
#
reg_ids = []
source_count = 0
reg_count = 0
SourceRecord.where({"source.fields":{"$elemMatch": {"776":{"$exists":1}}}, deprecated_timestamp:{"$exists":0}}).no_timeout.each do |sr|
  source_count += 1
  old_oclcs = sr.oclc_resolved
  old_issns = sr.issn_normalized
  old_isbns = sr.isbns_normalized
  sr.source = sr.source.to_json
  sr.save

  #something changed.
  if (old_oclcs & sr.oclc_resolved != sr.oclc_resolved) or
     (old_issns & sr.issn_normalized != sr.issn_normalized) or
     (old_isbns & sr.isbns_normalized != sr.isbns_normalized) 

    # get all the RegRecs it's associated with.
    RegistryRecord.where({source_record_ids: sr.source_id, 
                          deprecated_timestamp:{"$exists":0}}).no_timeout.each do |rr|
      reg_ids << rr.registry_id
    end
  end

end

reg_ids.uniq!

reg_ids.each do | reg_id |
  r = RegistryRecord.where({registry_id: reg_id}).first
  r.recollate
  r.save
end

puts "source count: #{source_count}"
puts "reg count: #{reg_ids.count}"
