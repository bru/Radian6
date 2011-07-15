require 'spec_helper'

describe Radian6::Topic do
  include Radian6SpecHelper
  
  topic_attributes = [:name, :groups, :id]
  describe ".from_xml" do
    context "nil parameter" do
      it 'should return a collection' do
        Radian6::Topic.from_xml(nil).should respond_to :each
      end
    end
    
    context "bad parameter" do
      it 'should return a collection' do
        Radian6::Topic.from_xml(27).should respond_to :each
      end
    end
    
    context "bad xml" do
      it 'should return a collection' do
        Radian6::Topic.from_xml('wibble').should respond_to :each
      end
    end   
    
    context "empty string" do
      it 'should return a collection' do
        Radian6::Topic.from_xml('').should respond_to :each
      end
    end     
    
    context "proccesing topics_xml" do
      it "should produce Radian6::Topics" do
        Radian6::Topic.from_xml(topics_xml).each do |topic| 
          topic.is_a?(Radian6::Topic).should be true       
        end
      end
    end 
  end
  
  describe "initialization" do  
    ['Radian6::Topic.new({})', 'Radian6::Topic.new(nil)', 'Radian6::Topic.new([])'].each do |subj|
      context "initializing with #{subj}" do
        subject { eval subj}
        topic_attributes.each do |method|
          its(method) { should be_empty }
        end
      end
    end
  end
end
