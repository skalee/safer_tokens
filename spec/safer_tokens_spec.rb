require_relative "spec_helper"

describe SaferTokens do

  describe ".token_in" do
    it "is always available in ActiveRecord" do
      ActiveRecord::Base.should respond_to :token_in
    end

    it "instantiates Column object for every column covered" do
      SaferTokens::Column.should_receive(:new)
        .with(:token, some: :options)
      SaferTokens::Column.should_receive(:new)
        .with(:another_token, some: :options)

      ExampleModel.class_eval do
        token_in :token, :another_token, some: :options
      end
    end

    it "allows defining token columns with different options" do
      SaferTokens::Column.should_receive(:new)
        .with(:token, some: :options)
      SaferTokens::Column.should_receive(:new)
        .with(:another_token, other: :options)

      ExampleModel.class_eval do
        token_in :token, some: :options
        token_in :another_token, other: :options
      end
    end

    it "defines method of names concluded from token columns"
  end

end
