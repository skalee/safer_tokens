RSpec.configure do |config|

  # Breaks parallelism by:
  # 1) having same model class name for all tests
  # 2) having it working on the same table
  # Possible optimization:
  # https://github.com/stefankroes/ancestry/blob/3508f299e/test/environment.rb
  config.before :example do
    model = Class.new ActiveRecord::Base
    model.table_name = "example_model"
    stub_const "ExampleModel", model
  end

end
