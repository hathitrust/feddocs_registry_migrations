# HT-548
# GPO ids in 035 fields have been turned into OCNs.
require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry
SR = SourceRecord

removed_src_ids = []
removed_ocns = []

num_reg_rec = RegistryRecord.where(deprecated_timestamp:{"$exists":0}).count
puts "Num of RegRecs prior:#{num_reg_rec}"

# 1. Take the list of gpo/ocn/source ids (regex_match_overlap.tsv) and
# re-extract ocns. 
src_data = ARGV.shift
File.open(src_data).each do |line|
  rec = line.split("\t")
  gids = rec[0].split(',')
  ocns = rec[1].split(',')
  srcid = rec[2]

  src = SR.find_by(source_id:srcid)
  old_ocns = src['oclc_resolved']
  src.extract_identifiers
  removed_ocns << old_ocns - src.oclc_resolved
   
# 2. Remove the source record from Registry Records. 
#
  src.remove_from_registry('Record removed from Registry for OCN reprocessing.')
  src.save 
end

# 3. Evaluate / deprecate all Registry Records that still have matching OCN
num_reg_recs_evalled = 0
num_reg_recs_removed = 0
removed_ocns.flatten.uniq.each do |ocn|
  RegistryRecord.where(oclcnum_t:ocn,
                       deprecated_timestamp:{"$exists":0}).no_timeout.each do |regrec|
    num_reg_recs_evalled += 1
    
    something_is_a_feddoc = false
    regrec.sources.each do |src|
      something_is_a_feddoc = true if src.fed_doc?
      src.extract_identifiers 
    end
    if !something_is_a_feddoc
      num_reg_recs_removed += 1
      regrec.sources.each do |src|
        src.remove_from_registry('No indication of being a U.S. Federal Document')
        src.deprecate('No indication of being a U.S. Federal Document. Erroneous OCLC number.')
      end
    else
      regrec.oclcnum_t = regrec.sources.collect(&:oclc_resolved).flatten.uniq
      regrec.save
    end
  end
end
puts "Num Reg Recs Evaluated:#{num_reg_recs_evalled}"
puts "Num Reg Recs Removed:#{num_reg_recs_removed}"


# 4. Go back through the list of source records, re-ingesting the bad records. 
num_not_feddocs = 0
num_updated = 0
File.open(src_data).each do |line|
  rec = line.split("\t")
  srcid = rec[2]
  src = SR.find_by(source_id:srcid)
  if !src.fed_doc?
    num_not_feddocs += 1
    src.in_registry = false
    src.save
    next
  end 
  num_updated += 1
  src.update_in_registry "Fixed OCNs"
  src.save
end
puts "Num Src Records not actually Fed Docs:#{num_not_feddocs}"
puts "Num Src Records updated:#{num_updated}"

num_reg_rec = RegistryRecord.where(deprecated_timestamp:{"$exists":0}).count
puts "Num reg recs after:#{num_reg_rec}"
