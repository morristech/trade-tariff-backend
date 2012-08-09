ENV["RAILS_ENV"] ||= 'test'

require 'simplecov'
require 'simplecov-rcov'

SimpleCov.start 'rails'
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter

require File.expand_path("../../config/environment", __FILE__)

require 'rspec/rails'
require 'rspec/autorun'
require 'json_expressions/rspec'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.infer_base_class_for_anonymous_controllers = false
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.include RSpec::Rails::RequestExampleGroup, type: :request,
                                                    example_group: { file_path: /spec\/api/ }

  config.include FactoryGirl::Syntax::Methods

  config.before(:all) do
    Sequel::Model.db.tables.each{|table| Sequel::Model.db.from(table).truncate}
  end

  config.around(:each) do |example|
    Sequel::Model.db.transaction(rollback: :always){example.run}
  end
end
