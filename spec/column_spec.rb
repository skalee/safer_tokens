# coding: utf-8

require_relative "spec_helper"

describe SaferTokens::Column do

  describe ".new" do
    subject{ SaferTokens::Column.method :new }

    it "sets challenge_column" do
      column_object = subject.(:some_column, {})
      column_object.challenge_column.should == :some_column
    end

    it "sets default column options unless overriden" do
      column_object = subject.(:some_column, {})
      column_object.invalidation_strategy.should == :nullify
      column_object.cryptography_provider.should be_kind_of SaferTokens::Cryptography::Cleartext
      column_object.challenge_generator.should == SaferTokens::Column::DEFAULT_CHALLENGE_GENERATOR
    end

    it "allows overriding column options" do
      options_arg = {
        invalidate_with: :destroy,
        secure_with: :bcrypt,
        generator: :given_generator,
      }
      column_object = subject.(:some_column, options_arg)
      column_object.invalidation_strategy.should == :destroy
      column_object.cryptography_provider.should be_kind_of SaferTokens::Cryptography::BCrypt
      column_object.challenge_generator.should == :given_generator
    end

    it "fails for unknown invalidation strategy" do
      proc{
        subject.(:some_column, invalidate_with: :unknown)
      }.should raise_exception ArgumentError
    end

    it "fails for unknown cryptography provider" do
      proc{
        subject.(:some_column, secure_with: :unknown)
      }.should raise_exception ArgumentError
    end
  end


  describe "#get_token" do
    subject{ column_definition.method :get_token }
    let(:column_definition){ SaferTokens::Column.new :token, {} }
    let(:model){ ExampleModel.new }

    it "decrypts challenge, builds token and returns it " \
        "when challenge is readable" do
      column_definition.should_receive(:challenge_readable?).and_return(true)
      column_definition.should_receive(:decrypt).and_return("decrypted")
      column_definition.should_receive(:build_token)
        .with(model, "decrypted")
        .and_return(:returned_token)
      subject.call(model).should == :returned_token
    end

    it "returns nil and does not attempt to read challenge " \
        "when challenge is not readable" do
      column_definition.should_receive(:challenge_readable?).and_return(false)
      subject.call(model).should be nil
    end
  end


  shared_examples "token generation" do
    let(:column_definition){ SaferTokens::Column.new :token, {} }
    let(:model){ ExampleModel.new }
    before{ column_definition.stub(:generate_challenge).and_return("123") }

    it "sets requested column" do
      proc{ subject.(model) }.should change{ model[:token] }.to("123")
    end

    it "returns token" do
      column_definition.stub(:build_token){ "token_for_model" }
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
      proc{ subject.(model) }.should raise_exception ActiveRecord::RecordInvalid
    end
  end


  describe "#invalidate_token" do
    subject{ column_definition.method :invalidate_token }
    let(:column_definition){ SaferTokens::Column.new :token, {} }
    let(:model){ ExampleModel.create token: "old token" }

    it "nullifies column and saves model for :nullify strategy" do
      column_definition.stub :invalidation_strategy => :nullify
      subject.call(model)
      model.reload
      model[:token].should be_nil
    end

    it "sets new challenge and saves model for :new strategy" do
      column_definition.stub :invalidation_strategy => :new
      column_definition.stub :generate_challenge => "new challenge"
      subject.(model)
      model.reload
      model[:token].should == "new challenge"
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


  describe "#build_token" do
    subject{ column_definition.method :build_token }
    let(:column_definition){ SaferTokens::Column.new :token, {} }
    let(:model){ ExampleModel.new }
    let(:column){ :token }
    let(:challenge){ "random_token" }

    before do
      model[:id] = "12345"
    end

    it "returns nil when model's id column is blank" do
      model[:id] = nil
      subject.call(model, challenge).should be nil
    end

    it "returns nil when challenge column is blank" do
      subject.call(model, nil).should be nil
    end

    it "returns secure token which parts are separated with dash" \
        "when both model's id challenge are present" do
      subject.call(model, challenge).should == "12345-random_token"
    end
  end


  describe "#parse_token" do
    subject{ column_definition.method :parse_token }
    let(:column_definition){ SaferTokens::Column.new :token, {} }

    it "splits token into id and challenge" do
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
    let(:relation){ ExampleModel.where(nil) }

    it "returns the model of which id and challenge do match" do
      token = "#{persisted_model.id}-some_token"
      subject.(relation, token).should == persisted_model
    end

    it "returns nil when id exists but challenge doesn't match" do
      token = "#{persisted_model.id}-not_this_token"
      subject.(relation, token).should be nil
    end

    it "returns nil when there is no record with matching id" do
      token = "#{persisted_model.id + 1}-some_token"
      subject.(relation, token).should be nil
    end
  end


  describe "#expend_token" do
    subject{ column_definition.method :expend_token }
    let(:column_definition){ SaferTokens::Column.new :token, {} }

    it "tries to fetch model with #use_token and" \
        " – if found – returns it and invalidates" do
      model_dbl = double
      column_definition.should_receive(:use_token)
        .with(:relation, :token)
        .and_return(model_dbl)
      column_definition.should_receive(:invalidate_token)
        .with(model_dbl)

      subject.(:relation, :token).should == model_dbl
    end

    it "tries to fetch model with #use_token and" \
        " – if not found – returns nil" do
      column_definition.should_receive(:use_token)
        .with(:relation, :token)
        .and_return(nil)
      column_definition.should_not_receive(:invalidate_token)

      subject.(:relation, :token).should be nil
    end
  end


  describe "#generate_challenge" do
    subject{ column_definition.method :generate_challenge }

    let(:column_definition){ SaferTokens::Column.new :token, {} }
    let(:model){ double }

    context "when challenge_generator is a proc" do
      let(:generator_proc){ proc{} }
      before{ column_definition.stub :challenge_generator => generator_proc }

      it "proxies the call to it" do
        generator_proc.should_receive(:call).with(model).and_return(:challenge)
        ret_val = subject.(model)
        ret_val.should be :challenge
      end
    end

    context "when challenge_generator is a symbol" do
      before{ column_definition.stub :challenge_generator => :symbol }

      it "uses :send to call indicated method on passed model" do
        model.should_receive(:send).with(:symbol).and_return(:challenge)
        ret_val = subject.(model)
        ret_val.should be :challenge
      end
    end
  end


  describe "::DEFAULT_CHALLENGE_GENERATOR" do
    subject{ SaferTokens::Column::DEFAULT_CHALLENGE_GENERATOR }

    it "returns 64-byte random in hexadecimal notation" do
      ret_val = subject.()
      ret_val.should match /\A[[:xdigit:]]{128}\Z/
    end
  end


  describe "#challenge_readable?" do
    subject{ column_definition.method :challenge_readable? }
    let(:column_definition){ SaferTokens::Column.new :token, {} }

    it "is true when cryptography_provider defines #decrypt" do
      crypto_dbl = double :decrypt => "decrypted"
      column_definition.stub :cryptography_provider => crypto_dbl
      subject.().should be true
    end

    it "is false when cryptography_provider does not define #decrypt" do
      crypto_dbl = double
      column_definition.stub :cryptography_provider => crypto_dbl
      subject.().should be false
    end
  end
end
