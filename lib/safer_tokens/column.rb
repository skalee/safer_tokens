module SaferTokens
  class Column

    attr_reader :token_column

    def initialize token_column, options
      @token_column = token_column
    end

    # Returns token for model basing on his +id+ and token column value.
    def get_token model
      token_segments = [model[:id], model[token_column]]
      token_segments.join "-" if token_segments.all?(&:present?)
    end

  end
end
