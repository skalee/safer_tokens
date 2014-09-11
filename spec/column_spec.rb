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

end
