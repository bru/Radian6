require 'spec_helper'
require 'radian6'

describe Radian6::Post do
  include Radian6SpecHelper
  post_attributes = %w{author avatar username title created_at updated_at id body source permalink}
  describe ".from_xml" do
    context "nil parameter" do
      it 'should return a collection' do
        Radian6::Post.from_xml(nil).should respond_to :each
      end
    end
    
    context "bad parameter" do
      it 'should return a collection' do
        Radian6::Post.from_xml(27).should respond_to :each
      end
    end
    
    context "bad xml" do
      it 'should return a collection' do
        Radian6::Post.from_xml('wibble').should respond_to :each
      end
    end   
    
    context "empty string" do
      it 'should return a collection' do
        Radian6::Post.from_xml('').should respond_to :each
      end
    end  
    
    context "proccesing recent_xml" do
      it "should produce Radian6::Posts" do
        Radian6::Post.from_xml(recent_xml).each do |post| 
          post.is_a?(Radian6::Post).should be true       
        end
      end
    end
  end
  
  describe "initialization" do  
    ['Radian6::Post.new({})', 'Radian6::Post.new(nil)', 'Radian6::Post.new([])'].each do |subj|
      context "initializing with #{subj}" do
        subject { eval subj}
        post_attributes.each do |method|
          its(method.to_sym) { should be_empty }
        end
      end
    end
  end  
end
