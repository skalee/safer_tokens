# coding: utf-8

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

ActiveRecord::Schema.define do

  create_table :example_model, force: true do |t|
    t.string :token
    t.string :another_token
    t.string :yet_another
  end

end
