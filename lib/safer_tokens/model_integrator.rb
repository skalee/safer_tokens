module SaferTokens
  module ModelIntegrator

    def token_in *args
      options, column_names = args.extract_options!, args
      column_names.each{ |col| SaferTokens::Column.new col, options }
    end

  end
end
