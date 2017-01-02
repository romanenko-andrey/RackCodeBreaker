require 'rspec'
require './lib/racker'
require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'

RSpec.configure do |config|
  config.include Capybara::DSL
  config.include Rack::Test::Methods
end