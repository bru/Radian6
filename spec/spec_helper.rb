require 'rubygems'
require 'bundler'
Bundler.setup

require 'rspec'
require 'webmock/rspec'

# require 'rspec/mocks/standalone'

require 'support/radian6_spec_helper.rb'
# Dir[File.firname.join("spec/support/**/*.rb")].each {|f| require f}
$: << File.join(File.dirname(__FILE__), '..', 'lib')
require 'radian6'

RSpec.configure do |config|
  config.mock_with :rspec

  config.before(:suite) do
    WebMock.disable_net_connect!(:allow_localhost => true)
  end
end
