require 'rubygems'
require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
end

Spork.each_run do
  # This code will be run each time you run your specs.
end

# --- Instructions ---
# - Sort through your spec_helper file. Place as much environment loading
#   code that you don't normally modify during development in the
#   Spork.prefork block.
# - Place the rest under Spork.each_run block
# - Any code that is left outside of the blocks will be ran during preforking
#   and during each_run!
# - These instructions should self-destruct in 10 seconds.  If they don't,
#   feel free to delete them.

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'simplecov'
SimpleCov.start 'rails'
SimpleCov.coverage_dir 'coverage/rspec'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'webmock/rspec'
# require 'socializer'

require 'testing/test_solr_server'
require 'testing/solr_test_helper'
require 'testing/socialcast_mock/mock'
require 'rspec/mocks/standalone'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
socialcast_mock = SocialcastMock::Mock.new

include SocialcastMock::Profile

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


  config.before(:suite) do
    # Make sure we can connect to localhost, e.g. to talk with Solr
    WebMock.disable_net_connect!(:allow_localhost => true)
    Socializer::CassandraHelper.mock_connection!
    mock_socialcast_profile_response
  end

  config.before(:each) do
    @socialcast_mock = socialcast_mock
    @socialcast_mock.clear!
    @socialcast_mock.mock_calls
  end

  config.after(:each) do
    # TODO move initialization to before(:suite)
    cassandra = Socializer::CassandraHelper.connection
    cassandra.clear_keyspace!
  end
end

include Testing::Ldap
include Testing::LoginMethods


