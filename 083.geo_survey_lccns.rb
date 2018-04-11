require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry
include Registry::Series
# https://lccn.loc.gov/n80029777
# Geological Survey records had a bad lccn, it was a title rather than entity.
# recollating should get us the correct lccns.
count = 0
RegistryRecord.where("$or":[{author_lccns:"https://lccn.loc.gov/n80029777"},
                            {added_entry_lccns:"https://lccn.loc.gov/n80029777"}],
                     deprecated_timestamp:{"$exists":0}).no_timeout.each do |reg|
  reg.recollate
  count += 1
end

puts "num of registry records recollated: #{count}" 
