require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry
include Registry::Series

govdoc = 0
not_govdoc = 0
#take a file of source_ids that can be found in solo REgRecs

open(ARGV.shift).each do | source_id |
  source_id.chomp!
  src = SourceRecord.where(source_id:source_id).first
  if src.nil?
    #puts "nil: #{source_id}"
  else
    if src.is_govdoc
      govdoc += 1
    else
      not_govdoc += 1
      puts [source_id,src.publisher_normalized,src.author_normalized,src.oclc_resolved,src.org_code].join("\t")
    end
  end
end
   
puts "#{govdoc} of solos are govdocs."
puts "#{not_govdoc} of solos are not govdocs."
