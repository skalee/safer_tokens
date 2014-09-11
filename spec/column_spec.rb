require_relative "spec_helper"

describe SaferTokens::Column do

  describe ".new" do
    subject{ SaferTokens::Column.method :new }

    it "sets token_column and options-related attributes" do
      column_object = subject.(:some_column, some: :options)
      column_object.token_column.should == :some_column
      skip "TODO options"
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

end
