require "spec_helper"

describe SaferTokens::Cryptography::BCrypt do

  it "is an irreversible algorithm" do
    subject.should respond_to :encrypt
    subject.should_not respond_to :decrypt
  end

  example "hashing and comparing" do
    encrypted = (subject.encrypt "big secret").to_s
    encrypted.should_not == "big secret"
    (subject.compare encrypted, "big secret").should be true
    (subject.compare encrypted, "wrong password").should be false
  end

end
