# DEPRECATED: We don't do this anymore. 
# List isn't updated, and anything already on the list is already deprecated.

require 'registry/registry_record'
require 'registry/source_record'
require './header' 
require 'pp'

include Registry
# consume a list of registry ids and deprecate  
# not deprecating related source ids
reg_count = 0

# use the Gsheet class
class RegIDList < Gsheet
  class << self; attr_accessor :reg_ids; end
  
  def self.sheet_id
    ENV['BLACKLISTED_REGISTRY_IDS']
  end

  #extract the registry id in case it's a full url
  def self.extract_id_from_url line
    return /(?:.*catalog\/)?(.*)(?:#)?/.match(line)[1]  
  end

  self.reg_ids = self.get_data.map {|line| self.extract_id_from_url(line)}.to_set
end

RegIDList.reg_ids.each do | reg_id |
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
