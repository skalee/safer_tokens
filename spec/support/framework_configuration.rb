RSpec.configure do |config|

  config.expect_with :rspec do |expectations|
    expectations.syntax = [:should]
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = [:should]
    mocks.verify_partial_doubles = true
  end

end
