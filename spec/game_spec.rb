require "rails_helper"

path = Rails.root.join("game/spec")
Dir.glob("#{path}/**/*_spec.rb") { |file| require file }
