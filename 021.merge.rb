require 'registry_record'
require 'source_record'
require './header' 
require 'pp'

# IAAS submitted ~200 Federal Register records with the enumchron of 
# \d+,\d+. That should be Volume and Number. 
#
# Normalize to what other contributors are doing, then try to merge.  

source_count = 0
reg_count = 0
oclcnums = [1768512,
            3803349,
            9090879,
            6141934,
            27183168,
            9524639,
            60637209,
            25816139,
            27163912,
            7979808,
            4828080,
            18519766,
            41954100,
            43080713,
            38469925,
            97118565,
            70285150 ]


RegistryRecord.where(oclcnum_t:1768512, 
                     enumchron_display:/^\d+,\d+$/, 
                     deprecated_timestamp:{"$exists":0}).no_timeout.each do |rec|
  source_count += 1
  m, volume, number = /^(\d+),(\d+)$/.match(rec.enumchron_display).to_a
  new_ec = "V. #{volume}:NO. #{number}"
  puts new_ec 
  existing = RegistryRecord.where(oclcnum_t:{"$in":oclcnums}, 
                           enumchron_display:/^#{new_ec}\D/, # miu has a trailing (<year>)
                           deprecated_timestamp:{"$exists":0}).first
  rec.enumchron_display = new_ec
  rec.save
  unless existing.nil?
    RegistryRecord::merge( [rec.registry_id, existing.registry_id], 
                           existing.enumchron_display, 
                           "#{REPO_VERSION}: Fix IAAS FR enum chrons.")


    reg_count += 1
  end
end
puts "Source records: #{source_count}"
puts "RegRecs: #{reg_count}"

