require 'registry/registry_record'
require 'registry/source_record'
require './header'
SourceRecord = Registry::SourceRecord
RegistryRecord = Registry::RegistryRecord

Dotenv.load!

Mongoid.load!(File.expand_path("../config/mongoid.yml", __FILE__), :development)

# Default ec parsing was turning all 4 digit ECs into years, even if they were
# less than 1800 and more than 2100. Current (partially fixed) parsing limits
# years to 1800 - 2099.  

src_recs_to_reparse = []
num_rr = 0

RegistryRecord.where(series:{"$exists":0},
                     enumchron_display:/^Year:(1[0-7]|2[1-9])\d{2}/,
                     deprecated_timestamp:{"$exists":0}).no_timeout.each do | rr |
  num_rr += 1
  src_recs_to_reparse << rr.source_record_ids
end

src_recs_to_reparse.flatten!.uniq!

puts "num src records reparsed: #{src_recs_to_reparse.count}"

src_recs_to_reparse.each do | sid |

  src = SourceRecord.where(source_id:sid).first
  begin
    src.source = src.source.to_json
    res = src.update_in_registry("Fixed 4 digit enumchron parsing. #{REPO_VERSION}")
    src.save
  rescue
    PP.pp src.source.to_json
    next
  end
end

puts "num rr dep:#{num_rr}"
