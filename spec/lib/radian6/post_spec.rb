require 'spec_helper'

describe Radian6::Post do
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
  end
  
  describe "initialization" do  
    ['Radian6::Post.new({})', 'Radian6::Post.new(nil)', 'Radian6::Post.new([])'].each do |subj|
      context "initializing with #{subj}" do
        subject { eval subj}
        %w{author avatar username title created_at updated_at id body source permalink}.each do |method|
          its(method.to_sym) { should be_empty }
        end
      end
    end
  end  
end
