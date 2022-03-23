require "rails_helper"

path = Rails.root.join("stats/spec")
Dir.glob("#{path}/**/*_spec.rb") { |file| require file }
