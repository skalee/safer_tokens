module SecureToken
  module ModelIntegrator

    def has_secure_token *args
      options, column_names = args.extract_options!, args
      column_names.each{ |col| SecureToken::Column.new col, options }
    end

  end
end
