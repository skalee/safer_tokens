require_relative "spec_helper"

describe SecureToken do

  it "works" do
    ExampleModel.new.should respond_to :token
  end

end
