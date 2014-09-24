# coding: utf-8

require_relative "spec_helper"

describe SaferTokens do

  describe "::token_in" do
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

    it "redefines attribute accessor" do
      ExampleModel.class_eval do
        token_in :token, :another_token
      end

      model = ExampleModel.new

      token_col_def = ExampleModel.safer_tokens_columns[:token]
      another_col_def = ExampleModel.safer_tokens_columns[:another_token]

      token_col_def.should_receive(:get_token)
        .with(model)
        .and_return(:proper_token)
      model.token.should == :proper_token

      another_col_def.should_receive(:get_token)
        .with(model)
        .and_return(:another_proper_token)
      model.another_token.should == :another_proper_token
    end

    it "defines finders of names concluded from token columns" do
      ExampleModel.class_eval do
        token_in :token, :another_token
      end

      token_col_def = ExampleModel.safer_tokens_columns[:token]
      another_col_def = ExampleModel.safer_tokens_columns[:another_token]

      token_col_def.should_receive(:use_token)
        .with(ExampleModel.all, :token_1)
      ExampleModel.use_token :token_1

      token_col_def.should_receive(:expend_token)
        .with(ExampleModel.all, :token_2)
      ExampleModel.expend_token :token_2

      another_col_def.should_receive(:use_token)
        .with(ExampleModel.all, :token_3)
      ExampleModel.use_another_token :token_3

      another_col_def.should_receive(:expend_token)
        .with(ExampleModel.all, :token_4)
      ExampleModel.expend_another_token :token_4
    end

    it "defines token setters of names concluded from token columns" do
      ExampleModel.class_eval do
        token_in :another_token
      end

      model = ExampleModel.new
      column_def = ExampleModel.safer_tokens_columns[:another_token]

      column_def.should_receive(:set_token).with(model).and_return(:new_token)
      ret_val = model.set_another_token
      ret_val.should == :new_token

      column_def.should_receive(:set_token!).with(model).and_return(:new_token)
      ret_val = model.set_another_token!
      ret_val.should == :new_token
    end
  end


  describe "::safer_tokens_columns" do
    it "is always available in ActiveRecord" do
      ActiveRecord::Base.should respond_to :safer_tokens_columns
    end

    it "returns hash" do
      ExampleModel.safer_tokens_columns.should be_kind_of Hash
    end
  end

end
