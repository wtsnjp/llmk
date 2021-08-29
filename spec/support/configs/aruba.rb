require 'aruba/rspec'
require 'aruba/api'

RSpec.configure do |config|
  config.include Aruba::Api
  config.before(:each) { setup_aruba }
end

Aruba.configure do |config|
  config.exit_timeout = 120
end
