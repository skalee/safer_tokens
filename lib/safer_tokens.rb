require "active_support/core_ext/module/delegation.rb"
require "active_record"

require "safer_tokens/version"

module SaferTokens
  autoload :Column, "safer_tokens/column"
  autoload :ModelIntegrator, "safer_tokens/model_integrator"

  module Cryptography
    autoload :BCrypt, "safer_tokens/cryptography/bcrypt"
    autoload :Cleartext, "safer_tokens/cryptography/cleartext"
    autoload :SCrypt, "safer_tokens/cryptography/scrypt"
  end
end

ActiveRecord::Base.extend SaferTokens::ModelIntegrator
