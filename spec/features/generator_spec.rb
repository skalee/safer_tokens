# coding: utf-8

require "spec_helper"

describe "Custom generators" do

  let(:token){ model.set_token! }
  let(:options){ {} }

  let(:model) do
    options_ = options # local variable is accessible in class_eval block

    ExampleModel.class_eval do
      token_in :token, options_

    private
      def custom_generator
        self[:id] + 100
      end
    end

    ExampleModel.create!
  end


  context "when no generator option is passed" do
    it "generates 128 digits long hexadecimal number" do
      model.set_token.should =~ /-[[:xdigit:]]{128}\Z/
    end
  end


  context "when lambda is passed as genertor option" do
    before{ options[:generator] = lambda{ |_| %w[rock paper scissors].sample } }

    it "generates challenge by calling given lambda" do
      model.set_token.should =~ /-(rock|paper|scissors)\Z/
    end
  end


  context "when symbol is passed as genertor option" do
    before{ options[:generator] = :custom_generator }

    it "generates challenge by calling referenced method" do
      model.set_token.should == "#{model.id}-#{model.id + 100}"
    end
  end

end
