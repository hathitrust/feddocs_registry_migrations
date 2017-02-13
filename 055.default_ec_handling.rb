require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry
include Registry::Series
# Parse enumchrons for records that are not a part of an identified series. 
# Default enumchron handling 
#
deprecate_count = 0

=begin
=end
source_count = 0
rr_count = 0
matched_count = 0
replacement_count = 0

# we want *Registry* Records with enumchrons but no series. 
#
# Each of these, parse their enumchron. 
RegistryRecord.where(series:{"$exists":0},
                     enumchron_display:{"$ne":""},
                     deprecated_timestamp:{"$exists":0},
                     last_modified:{"$lt":"ISODate('2017-02-12')"}).no_timeout.each do |reg|
  parsed = SourceRecord.parse_ec(reg.enumchron_display)
  if parsed.nil?
    #puts "its nil! #{reg.enumchron_display}"
    next
  end
  rr_count += 1

  exploded = SourceRecord.explode(parsed).keys[0]

  # we want to check if this registry record can be clustered with an already existing one
  # a fake src
  src = SourceRecord.new
  src.oclc_resolved = reg.oclcnum_t
  src.lccn_normalized = reg.lccn_t
  src.isbns_normalized = reg.isbn_t
  src.issn_normalized = reg.issn_t
  src.sudocs = reg.sudoc_display
  
  matched_rec = RegistryRecord.cluster(src, exploded)
  if !matched_rec.nil?
    #merge with matched one
    new_rec = RegistryRecord.merge([matched_rec, reg], 
                                   exploded, 
                                   "Improved enum/chron parsing. #{REPO_VERSION}")
    new_rec.source_record_ids.each {|i| puts i}
    matched_count += 1 
  else
    #create a replacement
    replacement = RegistryRecord.new(reg.source_record_ids, 
                                     exploded, 
                                     "Improved enum/chron parsing. #{REPO_VERSION}",
                                     [reg.registry_id])
    replacement.save
    reg.deprecate("Improved enum/chron parsing. #{REPO_VERSION}", replacement.registry_id)
    reg.source_record_ids.each {|i| puts i}
    replacement_count +=1
  end
end

puts "matched: #{matched_count}"
puts "replacements: #{replacement_count}"
  
