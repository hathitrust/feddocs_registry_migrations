require 'registry/registry_record'
require 'registry/source_record'
require './header'
SourceRecord = Registry::SourceRecord
RegistryRecord = Registry::RegistryRecord

# Take a single reg rec id and recollate it
Dotenv.load!

reg_rec_id = ARGV.shift
Mongoid.load!(ENV['MONGOID_CONF'], :production)

RegistryRecord.where(registry_id:reg_rec_id).no_timeout.each do |r|
  r.recollate
end
