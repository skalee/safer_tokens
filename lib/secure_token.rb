require "active_record"

require "secure_token/column"
require "secure_token/model"
require "secure_token/model_integrator"
require "secure_token/version"

ActiveRecord::Base.extend SecureToken::ModelIntegrator
