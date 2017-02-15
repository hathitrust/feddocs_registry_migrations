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
  begin
  src = SourceRecord.where(source_id: src_id).no_timeout.first

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
  
  src.source = src.source.to_json # re-extract enumchrons here
  src.save
  rescue
    PP.pp src
  end
  #we've already done this, because we started with the registry in 055
  # res = src.update_in_registry(" yada yada yada ") 
  
  srcs_updated += 1
end

puts "# of srcs updated: #{srcs_updated}"
