require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry
include Registry::Series
# Parse enumchrons for Statutes registry records 
# Previous enumchron_extraction code was buggy, creating duplicate enumchrons
# instead of sequential(exploded) enumchrons. Registry v. 0.9.2
#
deprecate_count = 0
source_count = 0
rr_count = 0

=begin
# Giving up on keeping existing records. Not worth the bookkeeping costs. 
=end
RegistryRecord.where(series:"Statutes At Large",
                     deprecated_timestamp:{"$exists":0}).no_timeout.each do |reg|
  reg.deprecate('Improved Statutes At Large enum/chron parsing.')
  deprecate_count += 1
end

# Re-extract all the Source Records
SourceRecord.where(series: "StatutesAtLarge",
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
  src.enum_chrons.each do | ec | 
    if regrec = RegistryRecord.where(series:"Statutes At Large", 
                                     deprecated_timestamp:{"$exists":0}, 
                                     enumchron_display:ec).first
      regrec.add_source(src)
    else
      regrec = RegistryRecord.new([src.source_id], ec, "Improved enum/chron parsing.")
      rr_count += 1
    end
    regrec.series = "Statutes At Large"
    regrec.save
  end
  src.save

end

puts "# new RegRecs: #{rr_count}"
puts "Deprecated records: #{deprecate_count}"
puts "Source records: #{source_count}"
