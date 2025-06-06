require_relative "boot"

require "rails"

# Pick the frameworks you want:
require "active_model/railtie"

# require "active_job/railtie"
require "active_record/railtie"

# require "active_storage/engine"
require "action_controller/railtie"

# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"

# require "action_cable/engine"
require "sprockets/railtie"

# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PitbossStats
  class Application < Rails::Application
    config.paths.add "game/lib", eager_load: true
    config.paths.add "notifications/lib", eager_load: true
    config.paths.add "stats/lib", eager_load: true

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    config.active_record.legacy_connection_handling = false

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.autoloader = :zeitwerk

    config.active_record.yaml_column_permitted_classes = [Symbol, ActiveSupport::Duration]

    config.after_initialize do
      puts Rails.configuration.active_record.yaml_column_permitted_classes
      Rails.configuration.active_record.yaml_column_permitted_classes << ActiveSupport::Duration
    end
  end
end
