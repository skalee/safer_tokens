module SaferTokens
  class Column

    DEFAULT_TOKEN_GENERATOR = proc{ SecureRandom.hex(64) }

    attr_reader :challenge_column, :invalidation_strategy,
      :cryptography_provider

    delegate :encrypt, :decrypt, :compare, to: :cryptography_provider

    def initialize challenge_column, options
      @challenge_column = challenge_column
      @invalidation_strategy = options[:invalidate_with] || :nullify

      case options[:secure_with]
      when :bcrypt
        cryptography_provider_class = Cryptography::BCrypt
      when :scrypt
        cryptography_provider_class = Cryptography::SCrypt
      when :cleartext, nil
        cryptography_provider_class = Cryptography::Cleartext
      else
        message = "Unknown cryptography provider: #{options[:secure_with]}"
        raise ArgumentError, message
      end
      @cryptography_provider = cryptography_provider_class.new
    end

    # Returns token for model basing on his +id+ and token column value.
    def get_token model
      if cryptography_provider.respond_to? :decrypt
        challenge = decrypt model[challenge_column]
        build_token model, challenge
      else
        nil
      end
    end

    # Sets the column to freshly generated challenge string and returns
    # the token.  Contrary to #set_token!, the model is not saved.
    # For new records returns +nil+ because +id+ is blank.
    def set_token model
      challenge = generate_challenge
      model[challenge_column] = encrypt challenge
      build_token model, challenge
    end

    # Similarly to #set_token, sets the column with freshly generated
    # value and returns the token.  Contrary to its bang-less counterpart,
    # the model is saved.  This has two implications:
    # 1. exception may be raised (from ActiveRecord::Base#save!)
    # 1. never returns +nil+ because record is persisted
    def set_token! model
      token = set_token model
      model.save!
      token
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
      when :nullify then model[challenge_column] = nil ; model.save!
      when :destroy then model.destroy
      when :delete then model.class.delete model.id
      else raise ArgumentError, "unknown token invalidation strategy"
      end
      nil
    end

    def matches? model, challenger
      compare model[challenge_column], challenger
    end

    def build_token model, challenge
      token_segments = [model[:id], challenge]
      token_segments.join "-" if token_segments.all?(&:present?)
    end

    # Verifies token correctness and splits it into segments: +id+
    # and +challenger+ string.
    def parse_token token
      segments = token && token.split("-")
      segments.try(:size) == 2 and segments or raise ArgumentError
    end

    def use_token relation, token
      id, challenger = parse_token token
      model = relation.find(id)
      model if matches? model, challenger
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def expend_token relation, token
      model = use_token relation, token
      invalidate_token model if model.present?
      model
    end

  private

    # Generates challenge string.
    def generate_challenge
      DEFAULT_TOKEN_GENERATOR.call
    end

  end
end
