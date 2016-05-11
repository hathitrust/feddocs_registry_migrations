require 'registry_record'
require 'source_record'
require './header' 
require 'pp'

# consume a list of registry ids and deprecate  
# not deprecating related source ids
reg_count = 0

fin = open(ARGV.shift)
fin.each do | line |
  #extract the registry id in case it's a full url
  reg_id = /(?:.*catalog\/)?(.*)(?:#)?/.match(line.split(/\t/)[0])[1]  
  if reg_id.length != 36
    #puts "bad reg id: #{reg_id}"
    next
  end

  regrec = RegistryRecord.where(registry_id: reg_id,
                               deprecated_timestamp: {"$exists":0}).first
  if regrec.nil?
    #non existent registry record
    next
  end

  reg_count += 1
  regrec.deprecate("#{REPO_VERSION}: Not a US Federal Document. Identified by registry identifier.")
end

puts "RegRecs deprecated: #{reg_count}"
