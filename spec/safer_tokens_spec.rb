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

    it "adds defined columns to .safer_tokens_columns class attribute" do
      SaferTokens::Column.should_receive(:new).exactly(3).times do |name, *_|
        :"column_definition_for_#{name}"
      end

      ExampleModel.class_eval do
        token_in :token, :another_token
        token_in :yet_another
      end

      ExampleModel.safer_tokens_columns.should == {
        token: :column_definition_for_token,
        another_token: :column_definition_for_another_token,
        yet_another: :column_definition_for_yet_another,
      }
    end

    it "defines method of names concluded from token columns"
  end


  describe ".safer_tokens_columns" do
    it "is always available in ActiveRecord" do
      ActiveRecord::Base.should respond_to :safer_tokens_columns
    end

    it "returns hash" do
      ExampleModel.safer_tokens_columns.should be_kind_of Hash
    end
  end

end
