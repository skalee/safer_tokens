require "spec_helper"

describe SaferTokens::Cryptography::Cleartext do

  it "is a reversible algorithm" do
    subject.should respond_to :encrypt
    subject.should respond_to :decrypt
  end

  example "encrypting and decrypting are no-ops" do
    encrypted = (subject.encrypt "big secret").to_s
    encrypted.should == "big secret"
    (subject.decrypt encrypted).should == "big secret"
  end

  example "comparison" do
    encrypted = (subject.encrypt "big secret").to_s
    (subject.compare encrypted, "big secret").should be true
    (subject.compare encrypted, "wrong password").should be false
  end

end
