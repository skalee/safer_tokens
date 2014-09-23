require "spec_helper"

describe "Cryptography integration" do

  let(:user){ User.create! }

  example "One can store challenge values in the cleartext" do
    User.class_eval do
      token_in :email_confirmation_token
    end

    user = User.create!

    token = user.set_email_confirmation_token!
    user.email_confirmation_token.
      should end_with user[:email_confirmation_token]
    (User.expend_email_confirmation_token token).should == user
  end

  example "One can store challenge values digested with scrypt" do
    User.class_eval do
      token_in :email_confirmation_token, secure_with: :scrypt
    end

    user = User.create!

    token = user.set_email_confirmation_token!
    token.should be_present
    token.should_not include user[:email_confirmation_token]
    (User.expend_email_confirmation_token token).should == user
  end

  example "One can store challenge values digested with bcrypt" do
    User.class_eval do
      token_in :email_confirmation_token, secure_with: :bcrypt
    end

    user = User.create!

    token = user.set_email_confirmation_token!
    token.should be_present
    token.should_not include user[:email_confirmation_token]
    (User.expend_email_confirmation_token token).should == user
  end

end
