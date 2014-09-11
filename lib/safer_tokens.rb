require "active_record"

require "safer_tokens/column"
require "safer_tokens/model"
require "safer_tokens/model_integrator"
require "safer_tokens/version"

ActiveRecord::Base.extend SaferTokens::ModelIntegrator
