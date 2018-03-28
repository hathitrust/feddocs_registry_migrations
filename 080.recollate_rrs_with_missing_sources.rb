# Registry records had references to 198902 Source Records that didn't exist.
# Search and destroy
require 'registry/registry_record'
require 'registry/source_record'
require 'pp'
require './header'
SourceRecord = Registry::SourceRecord
RegistryRecord = Registry::RegistryRecord

Dotenv.load!

Mongoid.load!(ENV['MONGOID_CONF'], :production)
num_recollated = 0

missing_source_ids = open(ARGV.shift) # data/missing_source_ids.txt
reg_recs_seen = []

missing_source_ids.each do |src_id|
  src_id.chomp!
  RegistryRecord.where(source_record_ids:src_id).no_timeout.each do |reg|
    #next if reg_recs_seen.include? reg.registry_id
    reg_recs_seen << reg.registry_id
    prev_sources = reg.source_org_codes
    prev_src_count = reg.source_record_ids.count
    reg.source_record_ids.delete(src_id)
    reg.recollate
    if reg.source_record_ids.include? src_id
      puts "wth"
      exit
    end
    PP.pp (prev_sources - reg.source_org_codes)
    num_recollated += 1
  end
end

puts "num recollated: #{num_recollated}"
