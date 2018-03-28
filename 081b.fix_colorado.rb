# Colorado has some messed up oclcs.
require 'registry/registry_record'
require 'registry/source_record'
require 'pp'
require './header'
SourceRecord = Registry::SourceRecord
RegistryRecord = Registry::RegistryRecord

Dotenv.load!

Mongoid.load!(ENV['MONGOID_CONF'], :production)

open(ARGV.shift).each do |line| # data/cou_bad_oclcs.txt
  oclcs = line.chomp.split(',').map {|o| o.to_i}
  o = oclcs.sort[0]
  # Get all registry records that have a bad and removed oclc
  RegistryRecord.where(oclcnum_t:o.to_i,
                      deprecated_timestamp:{"$exists":0}).no_timeout.each do |rr|
    # we keep it if any of them are fed docs
    next if rr.sources.any? do |s| 
      s.source = s.source.to_json
      s.fed_doc?
    end
 
    rr.deprecate("#{REPO_VERSION}: Not a US Federal Document. Identified by OCLC from COU bad oclc list." )
  
    # dump out the stragglers
    ht_url = 'https://hathitrust.org/usdocs_registry/catalog/'
    puts [
      ht_url + rr.registry_id,
      (rr['author_display'] || []).join(', '),
      rr.oclcnum_t.join(', '),
      (rr['publisher_t'] || []).join(', '),
      (rr.source_org_codes || []).join(', '),
      (rr['title_display'] || []).join(', ')
    ].join("\t")
  end
end
