require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

# Add a holdings field for HT records.

# 974
# c: org
# z: enum_chron
# s: digitizing agent
# r: rights
# u: holdings id 

puts ['HT id', 
      'Contributor',
      'Digitizing Agent',
      'Rights',
      'Holdings ID', 
      'Enum/Chron',
      'Year',
      'Procesed Enum/Chron'].join("\t")

# all HT records in registry
SourceRecord.where(org_code:"miaahdl",
                    deprecated_timestamp:{"$exists":0},
                  in_registry:true).no_timeout.each do |src|

  src.extract_holdings
  src.save
  #we want a tab delimited copy of this
  src.holdings.each do |ec, holdings|
    holdings.each do |hold|
      # print a line for each enum_chron holding
      puts [src.local_id,
            hold[:c].downcase,
            hold[:s],
            hold[:r],
            hold[:u],
            hold[:z],
            hold[:y],
            ec].join("\t")
    end #each logical enum_chron
  end #each 974
end #each HT source record
