require 'registry_record'
require 'source_record'
require './header' 

# After extraction of identifiers from 776, we have some source records that
# can go back in.  
source_count = 0
add_reg_count = 0
new_reg_count = 0
SourceRecord.where({deprecated_timestamp:{"$exists":0},
                    in_registry: false}).no_timeout.each do |src|
  if src.oclc_resolved.count == 0 and 
     src.isbns_normalized.count == 0 and
     src.issn_normalized.count == 0 and
     src.sudocs.count == 0 
    next
  end

  source_count += 1
  src.enum_chrons.each do | ec |
    if regrec = RegistryRecord::cluster( src, ec )
      regrec.add_source(src)
      regrec.save
      add_reg_count += 1
    else
      regrec = RegistryRecord.new([src.source_id], ec, "#{REPO_VERSION}: 015.cluster add")
      regrec.save
      new_reg_count += 1
    end
  end
  src.in_registry = true
  src.save

end
puts "SourceRecords updated: #{source_count}"
puts "add reg count: #{add_reg_count}"
puts "new reg count: #{new_reg_count}"

