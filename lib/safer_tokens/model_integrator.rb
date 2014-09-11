module SaferTokens
  module ModelIntegrator

    def token_in *args
      options, column_names = args.extract_options!, args
      column_names.each do |col|
        safer_tokens_columns[col] = SaferTokens::Column.new col, options
      end
    end

    def safer_tokens_columns
      @safer_tokens_columns ||= {}
    end

  end
end
