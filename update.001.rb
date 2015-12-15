require 'registry_record'
require 'source_record'
require './header'

#Her Majesty's Stationery Office
res = RegistryRecord.where(:publisher_normalized => ["HMSO"]).update_all(:publisher_viaf_ids => [134181633])
puts res
	
