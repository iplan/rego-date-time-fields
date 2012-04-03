$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'bundler/setup'

# first initialize full rails stack with dummy_app
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/dummy_app/config/environment")

# include rspec and rspec rails
require 'rspec'
require 'rspec/rails'

# next extend rails in the way this gem intends to
require 'rego-date-time-fields'
DateTimeFields::Railtie.new.run_initializers

# ----------------- db stuff ---------------------
# load models schema (create tables)
require "resources/db/schema"

# load models
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'models'))
Dir["#{File.dirname(__FILE__)}/resources/models/**/*.rb"].each {|f| require f}
# ----------------- end db stuff -----------------

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

# load factories for factory girl
require "factory_girl"
FactoryGirl.definition_file_paths = File.join(File.dirname(__FILE__), 'factories')
FactoryGirl.find_definitions

require 'database_cleaner'

RSpec.configure do |config|
  config.include RSpec::Rails::ViewExampleGroup, :type => :view, :example_group => {:file_path => 'spec/views'}

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
