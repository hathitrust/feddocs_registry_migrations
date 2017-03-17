require 'registry/registry_record'
require 'registry/source_record'
require './header'
SourceRecord = Registry::SourceRecord
RegistryRecord = Registry::RegistryRecord

Dotenv.load!

Mongoid.load!(File.expand_path("../config/mongoid.yml", __FILE__), :development)

# Some Illinois state docs have things that look like SuDocs, but aren't. 
# SourceRecord::extract_sudocs has been fixed. Just need to reprocess

num_rr_dep = 0
num_src_dep = 0

RegistryRecord.where(sudoc_display:/^IL/,
                     deprecated_timestamp:{"$exists":0}).no_timeout.each do | rr |
  num_rr_dep += 1
  
  rr.sources.each do | src |
    if src.deprecated_timestamp.nil?
      num_src_dep += 1
      src.deprecate("IL State Doc: #{REPO_VERSION}")
    end
  end

  rr.deprecate("IL State Doc: #{REPO_VERSION}")
  
end
  
puts "num rr dep:#{num_rr_dep}"
puts "num src dep: #{num_src_dep}"
