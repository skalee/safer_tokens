require "safer_tokens"

Dir[File.expand_path "../support/**/*.rb", __FILE__].each{ |f| require f }

I18n.enforce_available_locales = false
