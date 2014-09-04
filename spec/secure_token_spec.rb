require_relative "spec_helper"

describe SecureToken do

  describe ".has_secure_token" do
    it "is always available in ActiveRecord" do
      ActiveRecord::Base.should respond_to :has_secure_token
    end

    it "defines method of names concluded from token columns"
  end

end
