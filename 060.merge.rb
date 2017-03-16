require 'registry/registry_record'
require 'registry/source_record'
require './header'
SourceRecord = Registry::SourceRecord
RegistryRecord = Registry::RegistryRecord

Dotenv.load!

Mongoid.load!(File.expand_path("../config/mongoid.yml", __FILE__), :development)


num_new = 0
num_merged = 0
nil_cnt = 0

open(ARGV.shift).each do | line |
  oclc, enum = line.chomp.split(/,/, 2)
  enum ||= ''

  first = RegistryRecord.where(oclcnum_t:oclc.to_i,
                             enumchron_display:enum,
                             series:{"$exists":0},
                             deprecated_timestamp:{"$exists":0}).first
  if first.nil?
    nil_cnt +=1
    next
  end
  first['pub_date'] ||= []
  #see if we can find any matches for it
  cluster = RegistryRecord.where(oclcnum_t:oclc.to_i,
                                   enumchron_display:enum,
                                   pub_date:first['pub_date'],
                                   sudoc_display:first.sudoc_display,
                                   lccn_t:first.lccn_t,
                                   deprecated_timestamp:{"$exists":0},
                                   series:{"$exists":0}
                                   ).pluck(:registry_id)
  if cluster.count > 1
    num_new += 1
    num_merged += cluster.count
    r = RegistryRecord.merge(cluster, 
                         enum, 
                         "Reclustering:#{REPO_VERSION}")
    puts r.registry_id
  end
  
end

puts "num nil:#{nil_cnt}"
puts "num new: #{num_new}"
puts "num merged: #{num_merged}"
