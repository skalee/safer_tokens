RSpec.configure do |config|

  # Breaks parallelism by:
  # 1) having same model class name for all tests
  # 2) having it working on the same table
  # Possible optimization:
  # https://github.com/stefankroes/ancestry/blob/3508f299e/test/environment.rb
  config.before :example do
    [
      ["example_model", "ExampleModel"],
      ["users", "User"],
      ["api_tokens", "ApiToken"],
    ].each do |table_name, class_name|
      model = Class.new ActiveRecord::Base
      model.table_name = table_name
      stub_const class_name, model
    end
  end

end
