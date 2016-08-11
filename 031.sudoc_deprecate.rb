require 'registry_record'
require 'source_record'
require './header' 


count = 0
nongd = 0
regs = {}
reg_count = 0

#bad_out = open('regrecsources.json','w')

srcs = SourceRecord.where({deprecated_timestamp:{"$exists":0}, "non_sudocs.0":{"$exists":1}})

srcs.each do | src |
  count += 1
  if src.is_govdoc
    next
  else
    nongd += 1
    RegistryRecord.where({deprecated_timestamp:{"$exists":0}, source_record_ids:src.source_id}).each do | reg |
      reg_count += 1
      reg.deprecate("#{REPO_VERSION}: Not a United States Federal Document.")
      if !regs.has_key?(reg.registry_id)
        regs[reg.registry_id] = reg.source_record_ids
      end
    end
    src.deprecate("#{REPO_VERSION}: Not a United States Federal Document.")
    #bad_out.puts src.source.to_json
  end
  
end

puts "# source records with non-sudocs: #{count}"
puts "# nongd sources: #{nongd}"
puts "# of reglated Registry Regcords: #{reg_count}"
