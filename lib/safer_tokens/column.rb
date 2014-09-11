module SaferTokens
  class Column

    attr_reader :token_column

    def initialize token_column, options
      @token_column = token_column
    end

  end
end
