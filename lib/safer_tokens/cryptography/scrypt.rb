module SaferTokens
  module Cryptography
    class SCrypt

      def initialize
        require "scrypt"
      rescue LoadError
        $stderr.puts "You need bcrypt installed."
        raise
      end

      def encrypt value
        ::SCrypt::Password.create value
      end

      def compare stored_value, candidate
        ::SCrypt::Password.new(stored_value) == candidate
      end

    end
  end
end
