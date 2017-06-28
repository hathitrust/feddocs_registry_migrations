require 'registry/registry_record'
require 'registry/source_record'
require './header'
SourceRecord = Registry::SourceRecord
RegistryRecord = Registry::RegistryRecord

count = 0
nongd = 0
regs = {}
reg_count = 0

author_lccn = ARGV.shift
if author_lccn !~ /http/
  exit
end
srcs = SourceRecord.where({deprecated_timestamp:{"$exists":0}, 
                           author_lccns:author_lccn})

srcs.each do | src |
  count += 1
  #if src.is_govdoc
  #  next
  #else
    nongd += 1
    RegistryRecord.where({deprecated_timestamp:{"$exists":0}, source_record_ids:src.source_id}).each do | reg |
      reg_count += 1
      reg.deprecate("#{REPO_VERSION}: Not a United States Federal Document. Identified by author.")
      if !regs.has_key?(reg.registry_id)
        regs[reg.registry_id] = reg.source_record_ids
      end
    end
    src.deprecate("#{REPO_VERSION}: Not a United States Federal Document. Identified by author.")
    #bad_out.puts src.source.to_json
  #end
  
end

puts "# source records with non-sudocs: #{count}"
puts "# nongd sources: #{nongd}"
puts "# of related Registry Records: #{reg_count}"
