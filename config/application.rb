require_relative "boot"
require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_cable/engine"

Bundler.require(*Rails.groups)

module ProjectManagementApiRoxiler
  class Application < Rails::Application
    config.load_defaults 7.1
    config.autoload_lib(ignore: %w[assets tasks])
    config.api_only = true

    config.eager_load_paths += %W[
      #{config.root}/app/services
      #{config.root}/app/policies
      #{config.root}/app/serializers
    ]
  end
end
