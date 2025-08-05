source 'https://rubygems.org'

# A DSL for quickly creating web applications
# https://github.com/sinatra/sinatra
gem 'sinatra', '~> 2.1'

# An object-relational mapper
# https://guides.rubyonrails.org/active_record_basics.html
gem 'activerecord', '~> 6.1'

# Configures common Rake tasks for working with Active Record
# https://github.com/sinatra-activerecord/sinatra-activerecord
gem 'sinatra-activerecord'

# Run common tasks from the command line
# https://github.com/ruby/rake
gem 'rake'

# Provides functionality to interact with a SQLite3 database
# https://github.com/sparklemotion/sqlite3-ruby
gem 'sqlite3', '~> 1.4'

# Require all files in a folder
# https://github.com/jarmo/require_all
gem 'require_all'
gem 'base64'
gem 'bigdecimal'
gem 'mutex_m'
gem 'ostruct'
gem 'logger'
gem 'rack-contrib'
gem 'puma'
gem 'webrick'
# These gems will only be used when we are running the application locally
group :development do
  # Used to generate seed data
  # https://github.com/faker-ruby/faker
  gem 'faker', '~> 2.18'

  # Auto-reload the server when files are changed
  # https://github.com/alexch/rerun
  gem 'rerun'

  gem 'pry'
end

# These gems will only be used when we are running tests
group :test do
  gem 'database_cleaner'
  gem 'rspec'
  gem 'rack-test', '~> 1.1'
  gem 'rspec-json_expectations'
  gem 'rubocop'
end
