begin
  if ENV["RUN_COVERALLS"]
    require "coveralls"
    Coveralls.wear!
  end
rescue LoadError
  # ignore error for other test Gemfiles
end
