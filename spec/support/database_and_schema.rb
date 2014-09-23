# coding: utf-8

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

ActiveRecord::Schema.define do

  create_table :example_model, force: true do |t|
    t.string :token
    t.string :another_token
    t.string :yet_another
  end

  # Following tables are using in feature specs

  create_table :users, force: true do |t|
    t.string :email
    t.string :encrypted_password
    t.string :email_confirmation_token
    t.string :password_reset_token
  end

  create_table :api_tokens, force: true do |t|
    t.string :token
  end

end
