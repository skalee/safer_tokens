require "spec_helper"

describe "Expending tokens" do

  let(:token){ model.set_token! }
  let(:model) do
    strategy_ = strategy # local variable is accessible in class_eval block
    ExampleModel.class_eval do
      token_in :token, invalidate_with: strategy_
    end
    ExampleModel.create!
  end

  before do
    ExampleModel.class_eval do
      after_destroy :callback
      def callback ; end
    end
  end

  context "with :nullify strategy" do
    let(:strategy){ :nullify }

    it "nullifies challenge column" do
      expending(token).should change{ model.reload[:token] }.to(nil)
    end
  end

  context "with :new strategy" do
    let(:strategy){ :new }

    it "sets new challenge" do
      expending(token).should change{ model.reload[:token] }
      model[:token].should be_present
      model.token.should_not == token
    end
  end

  context "with :delete strategy" do
    let(:strategy){ :delete }

    it "removes record from database" do
      expending(token).should change{ ExampleModel.count }.by(-1)
    end

    it "does not run destroy callbacks" do
      ExampleModel.any_instance.should_not_receive :callback
      expending(token).()
    end
  end


  context "with :destroy strategy" do
    let(:strategy){ :destroy }

    it "removes record from database" do
      expending(token).should change{ ExampleModel.count }.by(-1)
    end

    it "runs destroy callbacks" do
      ExampleModel.any_instance.should_receive :callback
      expending(token).()
    end
  end

  def expending token
    proc{ ExampleModel.expend_token token }
  end

end
