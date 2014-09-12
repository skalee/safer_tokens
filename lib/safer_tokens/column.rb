module SaferTokens
  class Column

    DEFAULT_TOKEN_GENERATOR = proc{ SecureRandom.hex(64) }

    attr_reader :token_column, :invalidation_strategy

    def initialize token_column, options
      @token_column = token_column
      @invalidation_strategy = options[:invalidate_with] || :nullify
    end

    # Returns token for model basing on his +id+ and token column value.
    def get_token model
      token_segments = [model[:id], model[token_column]]
      token_segments.join "-" if token_segments.all?(&:present?)
    end

    # Sets the column with freshly generated value and returns the token.
    # Contrary to #set_token!, the model is not saved.  For new records
    # returns +nil+ because +id+ is blank.
    def set_token model
      new_token = DEFAULT_TOKEN_GENERATOR.call
      model[token_column] = new_token
      get_token model
    end

    # Similarly to #set_token, sets the column with freshly generated
    # value and returns the token.  Contrary to its bang-less counterpart,
    # the model is saved.  This has two implications:
    # 1. exception may be raised (from ActiveRecord::Base#save!)
    # 1. never returns +nil+ because record is persisted
    def set_token! model
      set_token model
      model.save!
      get_token model
    end

  end
end
