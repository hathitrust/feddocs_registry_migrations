require 'registry/source_record'
require './header'

# some sudocs are masquerading as enumchrons try to identify them
SourceRecord = Registry::SourceRecord
RR = Registry::RegistryRecord

RR.where(deprecated_timestamp:{"$exists":0},
          enumchron_display:{"$ne":""},
          "sudoc_display.0":{"$exists":1}).no_timeout.each do |reg|
  enum = reg.enumchron_display.gsub(/ /, '')
  sudocs = reg.sudoc_display.map {|s| s.gsub(/ /, '') }
  if sudocs.include? enum
    puts [reg.registry_id, reg.source_org_codes.join(","), reg.enumchron_display].join("\t")
  end
end
