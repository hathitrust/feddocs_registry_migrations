require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry
include Registry::Series
# Parse enumchrons for Congressional Serial Set registry records 
#
deprecate_count = 0
source_count = 0
rr_count = 0
r_labeled = 0
s_labeled = 0

=begin
#set series
RegistryRecord.where(sudoc_display:/^Y 1.1\/2:/,
                     deprecated_timestamp:{"$exists":0}).no_timeout.each do |reg|
  reg.series = "Congressional Serial Set"
  reg.save
  r_labeled += 1
end
SourceRecord.where(sudocs:/^Y 1.1\/2:/,
                   deprecated_timestamp:{"$exists":0}).no_timeout.each do |reg|
  reg.series = "CongressionalSerialSet"
  reg.save
  s_labeled += 1
end


=begin
  Deprecate them all and try it again. 

  Don't mess with empty string enum chrons. They might be something else in 
  the Y 1.1/2: stem space. 
#=end
RegistryRecord.where(series:"Congressional Serial Set",
                     enumchron_display:{"$ne":""},
                     deprecated_timestamp:{"$exists":0}).no_timeout.each do |reg|
  reg.deprecate('Improved enum/chron parsing.')
  deprecate_count += 1
end
=end

# Re-extract all the Source Records
SourceRecord.where(series: "CongressionalSerialSet",
                   deprecated_timestamp:{"$exists":0},
		   enum_chrons:{"$ne":[]},
		   last_modified:{"$lt":"ISODate('2016-10-28')"}).no_timeout.each do |src|
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
  src.enum_chrons.each do | ec | 
    next if ec == ''
    if regrec = RegistryRecord.where(series:"Congressional Serial Set", 
                                     deprecated_timestamp:{"$exists":0}, 
                                     enumchron_display:ec).first
      if !regrec.source_record_ids.include? src.source_id
        regrec.add_source(src)
      end
    else
      regrec = RegistryRecord.new([src.source_id], ec, "Improved enum/chron parsing. Nov1")
      rr_count += 1
    end
    regrec.series = "Congressional Serial Set"
    regrec.save
  end
  src.save

end

puts "# RegRecs labeled: #{r_labeled}"
puts "# Sources labeled: #{s_labeled}"
puts "# new RegRecs: #{rr_count}"
puts "Deprecated records: #{deprecate_count}"
puts "Source records: #{source_count}"
