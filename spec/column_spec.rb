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


  describe "#invalidate_token" do
    subject{ column_definition.method :invalidate_token }
    let(:column_definition){ SaferTokens::Column.new :token, {} }
    let(:model){ ExampleModel.new token: "old token" }

    it "nullifies column and saves model for :nullify strategy" do
      column_definition.stub :invalidation_strategy => :nullify
      subject.call(model)
      model.reload
      model[:token].should be_nil
    end

    it "sets new token and saves model for :new strategy" do
      column_definition.stub :invalidation_strategy => :new
      SaferTokens::Column::DEFAULT_TOKEN_GENERATOR.stub :call => "new token"
      subject.(model)
      model.reload
      model[:token].should == "new token"
    end

    it "destroys model for :destroy strategy" do
      column_definition.stub :invalidation_strategy => :destroy
      subject.(model)
      model.should be_destroyed
    end

    it "deletes model for :delete strategy" do
      column_definition.stub :invalidation_strategy => :delete
      subject.(model)
      model.should_not be_destroyed
      model.class.should_not exist model.id
    end

    it "fails for unknown strategy" do
      column_definition.stub :invalidation_strategy => :strange_strategy
      proc{
        subject.(model)
      }.should raise_exception ArgumentError
    end
  end


  describe "#parse_token" do
    subject{ column_definition.method :parse_token }
    let(:column_definition){ SaferTokens::Column.new :token, {} }

    it "splits token into id and verification" do
      subject.("1234-arbitrary_string").should == ["1234", "arbitrary_string"]
    end

    [nil, " ", "only_one_segment", "too-many-segments"].each do |token|
      it "fails when token looks invalid, as in #{token.inspect}" do
        proc{ subject.(token) }.should raise_exception ArgumentError
      end
    end
  end

  describe "#matches?" do
    subject{ column_definition.method :matches? }
    let(:column_definition){ SaferTokens::Column.new :token, {} }
    let(:model){ ExampleModel.new token: "some_token" }

    it "returns true when value stored in model's token column equals to " \
        "challenge argument" do
      subject.(model, "some_token").should be true
    end

    it "returns false otherwise" do
      subject.(model, "other_token").should be false
    end
  end


  describe "#use_token" do
    subject{ column_definition.method :use_token }
    let(:column_definition){ SaferTokens::Column.new :token, {} }
    let!(:persisted_model){ ExampleModel.create! token: "some_token" }

    it "returns the model of which id and token columns consist of valid id and value" do
      token = "#{persisted_model.id}-some_token"
      subject.(ExampleModel.all, token).should == persisted_model
    end

    it "id exists but value doesn't match" do
      token = "#{persisted_model.id}-not_this_token"
      subject.(ExampleModel.all, token).should be nil
    end

    it "there is no record with id fetched from record" do
      token = "#{persisted_model.id + 1}-some_token"
      subject.(ExampleModel.all, token).should be nil
    end
  end


  describe "#expend_token" do
    subject{ column_definition.method :expend_token }
    let(:column_definition){ SaferTokens::Column.new :token, {} }

    it "finds model with #use_token and – if found – returns it" \
        "and invalidates" do
      model_dbl = double
      column_definition.should_receive(:use_token)
        .with(:relation, :token)
        .and_return(model_dbl)
      column_definition.should_receive(:invalidate_token)
        .with(model_dbl)

      subject.(:relation, :token).should == model_dbl
    end

    it "finds model with #use_token and – if not found – returns nil" do
      column_definition.should_receive(:use_token)
        .with(:relation, :token)
        .and_return(nil)
      column_definition.should_not_receive(:invalidate_token)

      subject.(:relation, :token).should be nil
    end
  end

end
