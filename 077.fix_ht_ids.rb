require 'registry/registry_record'
require 'registry/source_record'
require './header'
SourceRecord = Registry::SourceRecord
RegistryRecord = Registry::RegistryRecord

# 3300 Registry Records have miaahdl source records but no ids in ht_ids_fv or ht_ids_lv
Dotenv.load!

Mongoid.load!(ENV['MONGOID_CONF'], :production)
num_reg_recs = 0
RegistryRecord.where(source_org_codes:"miaahdl",
                     "ht_ids_fv.0":{"$exists":0},
                     "ht_ids_lv.0":{"$exists":0},
                     deprecated_timestamp:{"$exists":0}).no_timeout.each do |r|
  r.recollate
  if r.ht_ids_fv.count.zero? && r.ht_ids_lv.count.zero?
    puts r.registry_id
    exit
  end
  num_reg_recs += 1
end
puts "num rr:#{num_reg_recs}"
