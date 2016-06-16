require 'registry_record'
require 'source_record'
require './header' 
require 'pp'

# We were taking the last 930$h as the enum chron from GPO records instead of the second. 

deprecate_count = 0
reg_count = 0
new_reg_count = 0 

# all GPO source records with enum_chrons
SourceRecord.where(org_code:"dgpo",
                    enum_chrons:{"$ne":[]},
                    deprecated_timestamp:{"$exists":0}).no_timeout.each do |src|
  # get the fixed enum chrons
  new_ec = src.extract_enum_chrons
  if new_ec.keys.count > 0
    new_enum_chrons = new_ec.collect do |k,fields|
      if !fields['canonical'].nil?
        fields['canonical']
      else
        fields['string']
      end
    end
  else
    new_enum_chrons = []
  end

  if new_enum_chrons.length == 0
    new_enum_chrons << ''
  end

  #get rid of bad old ones
  (src.enum_chrons - new_enum_chrons).each do |ec|
    RegistryRecord.where(source_record_ids: [src.source_id], 
                         enumchron_display: ec,
                         deprecated_timestamp:{"$exists":0}).no_timeout.each do |r|
      deprecate_count += 1
      r.deprecate("#{REPO_VERSION}: Original GPO record processing used incorrect Enumeration/Chronology fields.")
    end
  end

  #cluster new ones
  (new_enum_chrons - src.enum_chrons).each do |ec|
    if regrec = RegistryRecord.cluster(src, ec)
      regrec.add_source(src)
      reg_count +=1
    else
      new_reg_count += 1
      regrec = RegistryRecord.new([src.source_id], ec, 
                                  "#{REPO_VERSION}: Fixing GPO record Enumeration/Chronology.")
    end
    regrec.save
  end

  #set the new enum_chrons
  src.enum_chrons = new_enum_chrons
  src.ec = new_ec
  src.save
end

puts "Registry Records deprecated: #{deprecate_count}"                   
puts "RegRecs clustered: #{reg_count}"
puts "New RegRecs: #{new_reg_count}"

