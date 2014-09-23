module SaferTokens
  module Cryptography
    class BCrypt

      def initialize
        require "bcrypt"
      rescue LoadError
        $stderr.puts "You need bcrypt installed."
        raise
      end

      def encrypt value
        ::BCrypt::Password.create value
      end

      def compare stored_value, candidate
        ::BCrypt::Password.new(stored_value) == candidate
      end

    end
  end
end
