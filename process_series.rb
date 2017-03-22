require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry
include Registry::Series

# Generic utility for processing a series

def get_selector series
  selector = nil
  case
  when (!eval(series).oclcs.nil? and
        eval(series).oclcs.count > 0 and
        eval(series).respond_to?(:sudoc_stem) and
        !eval(series).sudoc_stem.nil?)
    selector = SourceRecord.or({oclc_resolved:{"$in":eval(series).oclcs}},
                           {sudocs:/^#{Regexp.escape(eval(series).sudoc_stem)}/}).selector
  when (!eval(series).oclcs.nil? and eval(series).oclcs.count > 0)
    selector = SourceRecord.where({oclc_resolved:{"$in":eval(series).oclcs}}).selector
  when !eval(series).sudoc_stem.nil? 
    selector = SourceRecord.where({sudocs:/^#{Regexp.escape(eval(series).sudoc_stem)}/}).selector
  else
    raise 'Can not determine selector for given series.'
  end
  PP.pp selector
  return selector
end


source_count = 0
before_rr_count = 0
after_rr_count = 0

series, *update_message = ARGV

if update_message.count == 0
  update_message = "Improved enum/chron parsing." 
end

if series.nil? or series == '' or series =~ /\s/
  puts "We need a series name."
  exit
end

# Registry records get a more human friendly series title
human_series = series.gsub(/([A-Z])/, ' \1').strip

# initial src numbers
before_src_count = SourceRecord.where(series:series,
                                      deprecated_timestamp:{"$exists":0}).count
puts "Before processing, there are #{before_src_count} Source records for this series."

# 1. Label our series records
# some are identified by oclcs, some by sudoc_stem, some by both
num_found = 0
SourceRecord.where(deprecated_timestamp:{"$exists":0})
            .and( get_selector(series) ).no_timeout.each do | src |
  num_found += 1
  src.series = series
  src.save
  RegistryRecord.where(source_record_ids:src.source_id,
                       series:{"$ne":human_series}).no_timeout.each do | r |
    r.series = human_series
    r.save
  end
end

# 2. get some initial numbers
before_rr_count = RegistryRecord.where(series:human_series,
                                       deprecated_timestamp:{"$exists":0}).count
puts "Before processing, there are #{before_rr_count} Registry Records for this series."

puts "num_found: #{num_found}"

#3. reprocess
SourceRecord.where(series:series, 
                   deprecated_timestamp:{"$exists":0}).no_timeout.each do |src|
  src.source = src.source.to_json #re-extraction done here
  res = src.update_in_registry("Improved enum/chron parsing. #{REPO_VERSION}") #this will take care of everything
  deprecate_count += res[:num_deleted]
  rr_count += res[:num_new]
  src.save
end

# what have we done!?
after_src_count = SourceRecord.where(series:series,
                                      deprecated_timestamp:{"$exists":0}).count
after_rr_count = RegistryRecord.where(series:human_series,
                                      deprecated_timestamp:{"$exists":0}).count
puts "After processing, there are #{after_src_count} source records for this series."
puts "After processing, there are #{after_rr_count} Registry records for this series."

