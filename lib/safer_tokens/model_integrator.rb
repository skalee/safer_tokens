module SaferTokens
  module ModelIntegrator

    def token_in *args
      options, column_names = args.extract_options!, args
      column_names.each do |col|
        safer_tokens_columns[col] = SaferTokens::Column.new col, options
        define_methods col
      end
    end

    def safer_tokens_columns
      @safer_tokens_columns ||= {}
    end

  private

    def define_methods column_name
      define_singleton_method "use_#{column_name}" do |token|
        safer_tokens_columns[column_name].use_token where(nil), token
      end

      define_singleton_method "expend_#{column_name}" do |token|
        safer_tokens_columns[column_name].expend_token where(nil), token
      end

      define_method column_name do
        self.class.safer_tokens_columns[column_name].get_token self
      end

      define_method "set_#{column_name}" do
        self.class.safer_tokens_columns[column_name].set_token self
      end

      define_method "set_#{column_name}!" do
        self.class.safer_tokens_columns[column_name].set_token! self
      end
    end

  end
end
