require_relative "spec_helper"

describe SecureToken do

  describe ".has_secure_token" do
    it "is always available in ActiveRecord" do
      ActiveRecord::Base.should respond_to :has_secure_token
    end

    it "instantiates Column object for every column covered" do
      SecureToken::Column.should_receive(:new)
        .with(:token, some: :options)
      SecureToken::Column.should_receive(:new)
        .with(:another_token, some: :options)

      ExampleModel.class_eval do
        has_secure_token :token, :another_token, some: :options
      end
    end

    it "allows defining token columns with different options" do
      SecureToken::Column.should_receive(:new)
        .with(:token, some: :options)
      SecureToken::Column.should_receive(:new)
        .with(:another_token, other: :options)

      ExampleModel.class_eval do
        has_secure_token :token, some: :options
        has_secure_token :another_token, other: :options
      end
    end

    it "defines method of names concluded from token columns"
  end

end
