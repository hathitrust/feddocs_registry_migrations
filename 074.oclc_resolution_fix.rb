require 'registry/source_record'
require './header'

# Previously, if a record had multiple oclcs and one of them successfully resolved,
# the rest got nuked. We don't want that to happen. 
SourceRecord = Registry::SourceRecord

num_checked = 0
num_diff = 0
SourceRecord.where(deprecated_timestamp:{"$exists":0}, 
                   in_registry:true).no_timeout.each do |src|
  num_checked += 1
  resolved = src.oclc_alleged.map{|o| resolve_oclc(o) }.flatten.uniq
  if resolved != src.oclc_resolved
    src.oclc_resolved = resolved
    src.save
    num_diff += 1
  end
end

puts "num checked: #{num_checked}"
puts "num diff: #{num_diff}"
