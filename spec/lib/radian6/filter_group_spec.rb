require 'spec_helper'

describe Radian6::FilterGroup do
  
  describe "initialization" do  
     filter_group_attributes = [:name, :queries, :id]
     ['Radian6::FilterGroup.new({})', 'Radian6::FilterGroup.new(nil)', 'Radian6::FilterGroup.new([])'].each do |subj|
       context "initializing with #{subj}" do
         subject { eval subj}
         filter_group_attributes.each do |method|
           its(method.to_sym) { should be_empty }
         end
       end
     end
   end  
  
end
