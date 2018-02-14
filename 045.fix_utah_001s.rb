require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry
include Registry::Series

# Utah ingested MvI records incorrectly, interpreting GPO id numbers
# as OCLCs 
#
rr_deprecate_count = 0
rr_recollate = 0
source_deprecate_count = 0
ht_deprecate_count = 0
ht_reg_dep_count = 0

SourceRecord.where(org_code:"ula",
                   source_blob:/"001":"ocm.*"001":"ocm/).no_timeout.each do |src|
  source_deprecate_count += 1
  src.deprecate("#{REPO_VERSION}: Bad OCLC numbers from Utah.")

  #find associated RegRecs
  RegistryRecord.where(source_record_ids:src.source_id,
                       deprecated_timestamp:{"$exists":0}).no_timeout.each do |regrec|
    if regrec.source_record_ids.count == 1
      regrec.deprecate("#{REPO_VERSION}: Bad OCLC numbers from Utah.")
      rr_deprecate_count += 1
    else
      regrec.source_record_ids.delete(src.source_id)
      regrec.save
      regrec.recollate
      rr_recollate += 1

      if regrec.source_record_ids.include? src.source_id
	      puts "wtf"
      end

      #figure out which OCLC only Utah had
      bad_oclcs = src.oclc_resolved - regrec.oclcnum_t
      #use the bad oclcs to find the bad HT records
      bad_oclcs.each do |oclc|
        SourceRecord.where(org_code:"miaahdl",
                           oclc_resolved:oclc,
                           deprecated_timestamp:{"$exists":0}).no_timeout.each do |ht_src|
          if !ht_src.fed_doc?
            ht_src.deprecate("#{REPO_VERSION}: Bad OCLC numbers from Utah.")
            ht_deprecate_count += 1
            RegistryRecord.where(source_record_ids:[ht_src.source_id],
                                 deprecated_timestamp:{"$exists":0}).no_timeout.each do |ht_reg|
              ht_reg.deprecate("#{REPO_VERSION}: Bad OCLC numbers from Utah.")
              ht_reg_dep_count += 1
            end
          end
        end
      end #bad_oclcs
    end #recollation, identification of bad oclcs
  end #associated regrecs
end #each utah source
    
puts "rr_deprecate_count:#{rr_deprecate_count}"
puts "rr_recollate:#{rr_recollate}"
puts "source_deprecate_count:#{source_deprecate_count}"
puts "ht_deprecate_count:#{ht_deprecate_count}"
puts "ht_reg_dep_count:#{ht_reg_dep_count}"
