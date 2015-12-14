if `git status -s` != ''
  puts "Git repo not clean and current. Commit and try again."
  exit
end

# Need to track which repo version deprecated something
REPO_VERSION = `git rev-parse HEAD`.strip

Mongoid.load!("config/mongoid.yml", :development)

Mongo::Logger.logger.level = ::Logger::FATAL
