require "rails_helper"

path = Rails.root.join("notifications/spec")
Dir.glob("#{path}/**/*_spec.rb") { |file| require file }
