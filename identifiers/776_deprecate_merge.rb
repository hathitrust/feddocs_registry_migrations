require 'registry_record'
require 'source_record'
require './header' 

# There are still 123401 reg recs with enumchron of "ONLINE"
# Many but not all of these are MSU records. Many of the source records
# also have OCLCs in their 776 which were previously ignored. 
#
# Find source recs with 776. Re-extract their identifiers. If they changed, 
# recluster. 
#
source_count = 0
reg_count = 0
o_count = 0
SourceRecord.where({"source.fields":{"$elemMatch": {"776":{"$exists":1}}}, deprecated_timestamp:{"$exists":0}}).no_timeout.each do |sr|
  source_count += 1
  old_oclcs = sr.oclc_resolved
  old_issns = sr.issn_normalized
  old_isbns = sr.isbns_normalized
  sr.source = sr.source 

  #something changed.
  if (old_oclcs & sr.oclc_resolved != sr.oclc_resolved) or
     (old_issns & sr.issn_normalized != sr.issn_normalizedj) or
     (old_isbns & sr.isbns_normalized != sr.isbns_normalized) 

    # stupid ONLINE enumchron 
    # sr.enum_chrons.delete("ONLINE")
    ecs = sr.enum_chrons
    ecs.delete("ONLINE")

    #recluster
    new_reg_recs = []
    ecs.each do | ec |
      r = RegistryRecord::cluster(s, ec)
      if r
        new_reg_recs[r.registry_id] = r
      end
     
      # can't save them yet. need to check the old stuff 
      #r.add_source( sr )
    end

    # We could use RegistryRecord:merge, but thats messy in this case 
    RegistryRecord.where({source_record_ids: sr.source_id}).no_timeout.each do | old_rr |
      if new_reg_recs.has_key? old_rr.registry_id
        next
      end #else

      reg_count += 1
      if old_rr.enumchron_display == "ONLINE"
        old_rr.enumchron_display == ""
        o_count += 1
      end
  
      #old_rr.deprecate("#{REPO_VERSION}: Extracting 776s fixed some things. 
    end

    #new_reg_recs.each do |rid, rec|
      #rec.add_source( sr )
    #end
  end

puts "source count: #{source_count}"
puts "reg count: #{reg_count}"
puts "online count: #{o_count}"
