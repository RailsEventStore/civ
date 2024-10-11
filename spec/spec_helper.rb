RSpec.configure do |config|
  ENV["RAILS_ENV"] = "test"

  $LOAD_PATH.push(File.expand_path("../../game/lib", __FILE__))
  $LOAD_PATH.push(File.expand_path("../lib", __FILE__))

  require "game"
  require "ruby_event_store/rspec"
  require "rails_helper"

end
