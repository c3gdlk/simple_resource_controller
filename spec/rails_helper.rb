# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'simplecov'

SimpleCov.profiles.define 'gem' do
  add_filter 'spec'
  add_group 'Libraries', 'lib/simple_resource_controller'
end

SimpleCov.start 'gem'

require 'spec_helper'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path('../dummy_app/config/environment', __FILE__)
require 'rspec/rails'


support_path = File.expand_path('../support/**/*.rb', __FILE__)
Dir[support_path].each { |f| require f }

ActiveRecord::Migration.verbose = true
ActiveRecord::Migrator.migrate(File.expand_path("../dummy_app/db/migrate/", __FILE__))

RSpec.configure do |config|
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false
end
