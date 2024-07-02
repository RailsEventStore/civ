RSpec.configure do |config|
  config.expect_with(:rspec) do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with(:rspec) do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.order = :random

  Kernel.srand(config.seed)

  ENV["RAILS_ENV"] = "test"

  $LOAD_PATH.push(File.expand_path("../../game/lib", __FILE__))

  require "game"
  require "ruby_event_store/rspec"

end
