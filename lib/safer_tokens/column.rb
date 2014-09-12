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

    # Invalidates token.  Database is always altered (model is saved, destroyed
    # or deleted)
    # +:new+:: generate new token and set the column to it
    # +:nullify+:: set the column to nil
    # +:destroy+:: destroy the model
    # +:delete+:: delete the model without triggering callbacks
    def invalidate_token model
      case invalidation_strategy
      when :new then set_token! model
      when :nullify then model[token_column] = nil ; model.save!
      when :destroy then model.destroy
      when :delete then model.class.delete model.id
      else raise ArgumentError, "unknown token invalidation strategy"
      end
      nil
    end

    def matches? model, challenger
      secure_compare model[token_column], challenger
    end

    # Verifies token correctness and splits it into segments: +id+
    # and +challenger+ string.
    def parse_token token
      segments = token && token.split("-")
      segments.try(:size) == 2 and segments or raise ArgumentError
    end

  private

    # Constant-time comparison algorithm to prevent timing attacks.  Copied from
    # ActiveSupport::MessageVerifier.
    # https://github.com/rails/rails/blob/08754f12e6/activesupport/lib/active_support/message_verifier.rb
    def secure_compare a, b
      return false unless a.bytesize == b.bytesize

      l = a.unpack "C#{a.bytesize}"

      res = 0
      b.each_byte { |byte| res |= byte ^ l.shift }
      res == 0
    end

  end
end
