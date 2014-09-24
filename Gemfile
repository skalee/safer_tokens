source "https://rubygems.org"

# Specify your gem's dependencies in secure_token.gemspec
gemspec

platforms :ruby do
  gem "sqlite3"
end

platforms :jruby do
  gem "activerecord-jdbc-adapter"
  gem "activerecord-jdbcsqlite3-adapter"
end

platform :mri_21 do
  gem "coveralls", require: false if ENV["TRAVIS"]
end
