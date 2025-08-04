ENV['RACK_ENV'] ||= 'development'

# Require logger first for Ruby 3.3+ compatibility
require 'logger'

# Require in Gems
require 'bundler/setup'
Bundler.require(:default, ENV.fetch('RACK_ENV', nil))

# Require in all files in 'app' directory
require_all 'app'
