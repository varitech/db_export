require 'rspec'
require File.expand_path('../support/environment', __FILE__)
require 'ccp_dbmodel'
require 'db_export'
require 'support/database'
require 'support/matchers'
require 'support/seed_data_helper'
require 'date'

RSpec.configure do |config|
  config.mock_with :rspec

  config.include RSpec::Expectations
  config.include RSpec::Matchers
  config.include SeedDataHelper
  
  config.before(:suite) do
  end

  config.before(:each) do
    DatabaseCleaner.clean unless ENV['DONT_CLEAN']
    setup_billing_periods
  end

  config.after(:each) do |scenario|
    $stdin.getc if (ENV['WAIT_ON_ERROR'] && scenario.failed?) || ENV['WAIT_FOR_ME']
  end
end

