require "active_support/core_ext/module/delegation.rb"
require "active_record"

require "safer_tokens/column"
require "safer_tokens/cryptography/bcrypt"
require "safer_tokens/cryptography/cleartext"
require "safer_tokens/cryptography/scrypt"
require "safer_tokens/model_integrator"
require "safer_tokens/version"

ActiveRecord::Base.extend SaferTokens::ModelIntegrator
