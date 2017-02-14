require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry
include Registry::Series
# Parse enumchrons for records that are not a part of an identified series. 
# This takes care of the source records that we previously left alone
# Default enumchron handling 
#

srcs_updated = 0

# we want *SourceRecord* Records with enumchrons but no series. 
#
# Each of these, parse their enumchron. 

open(ARGV.shift).each do | line |
  src_id = line.chomp

  src = SourceRecord.where(source_id: src_id).no_timeout.first
  src.source = src.source.to_json # re-extract enumchrons here
  src.save
  #we've already done this, because we started with the registry in 055
  # res = src.update_in_registry(" yada yada yada ") 
  
  srcs_updated += 1
end

puts "# of srcs updated: #{srcs_updated}"
