require_relative "spec_helper"

describe SaferTokens::Column do

  describe ".new" do
    subject{ SaferTokens::Column.method :new }

    it "sets token_column" do
      column_object = subject.(:some_column, {})
      column_object.token_column.should == :some_column
    end

    it "sets default column options unless overriden" do
      column_object = subject.(:some_column, {})
      column_object.invalidation_strategy.should == :nullify
    end

    it "allows overriding column options" do
      options_arg = {
        invalidate_with: :destroy,
      }
      column_object = subject.(:some_column, options_arg)
      column_object.invalidation_strategy.should == :destroy
    end
  end


  describe "#get_token" do
    subject{ column_definition.method :get_token }
    let(:column_definition){ SaferTokens::Column.new :token, {} }
    let(:model){ ExampleModel.new }
    let(:column){ :token }

    before do
      model[:token] = "random_token"
      model[:id] = "12345"
    end

    it "returns nil when model's id column is blank" do
      model[:id] = nil
      subject.call(model).should be nil
    end

    it "returns nil when model's token column is blank" do
      model[:token] = nil
      subject.call(model).should be nil
    end

    it "returns secure token which parts are separated with dash" \
        "when both id and token model's columns are present" do
      subject.call(model).should == "12345-random_token"
    end
  end


  shared_examples "token generation" do
    let(:column_definition){ SaferTokens::Column.new :token, {} }
    let(:model){ ExampleModel.new }

    it "sets requested column" do
      proc{ subject.(model) }.should change{ model[:token] }
    end

    it "returns token" do
      column_definition.stub(:get_token){ "token_for_model" }
      subject.(model).should == "token_for_model"
    end
  end


  describe "#set_token" do
    subject{ column_definition.method :set_token }

    include_examples "token generation"

    it "does not save the model" do
      proc{ subject.(model) }.should_not change{ model.persisted? }
    end
  end


  describe "#set_token!" do
    subject{ column_definition.method :set_token! }

    include_examples "token generation"

    it "saves the model" do
      proc{ subject.(model) }.should change{ model.persisted? }
    end

    it "raises exception when model validations fail" do
      model.stub(:valid? => false)
      proc{ subject.(model) }.should raise_exception
    end
  end

end
