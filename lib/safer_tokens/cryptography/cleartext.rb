module SaferTokens
  module Cryptography
    # No-op dummy key derivation function.  It really does nothing.  Output
    # equals input.  Simplifies Safer Tokens gem design.
    class Cleartext

      def encrypt value
        value
      end

      def decrypt value
        value
      end

      # Constant-time comparison algorithm to prevent timing attacks.  Copied from
      # ActiveSupport::MessageVerifier.
      # https://github.com/rails/rails/blob/08754f12e6/activesupport/lib/active_support/message_verifier.rb
      def compare a, b
        return false unless a.bytesize == b.bytesize

        l = a.unpack "C#{a.bytesize}"

        res = 0
        b.each_byte { |byte| res |= byte ^ l.shift }
        res == 0
      end

    end
  end
end
