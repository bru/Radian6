# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'webmock/rspec'
require 'socializer/cassandra_helper'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

DatabaseCleaner.strategy = :truncation

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.before :each do
    DatabaseCleaner.start
    DatabaseCleaner.clean
  end

  config.before(:suite) do
    # Make sure we can connect to localhost, e.g. to talk with Solr
    WebMock.disable_net_connect!(:allow_localhost => true)
  end

  config.after(:each) do
    # TODO move initialization to before(:suite)
    cassandra = Socializer::CassandraHelper.get_for_env(ENV["RAILS_ENV"])
    cassandra.clear_keyspace!
  end
end

include Testing::Ldap
