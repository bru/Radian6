require 'spec_helper'

describe Radian6::FilterQuery do
  describe "initialization" do  
    filter_query_attributes = [ :query, :isExcludeQuery, :id]
    ['Radian6::FilterQuery.new({})', 'Radian6::FilterQuery.new(nil)', 'Radian6::FilterQuery.new([])'].each do |subj|
      context "initializing with #{subj}" do
        subject { eval subj}
        filter_query_attributes.each do |method|
          its(method.to_sym) { should be_empty }
        end
      end
    end
  end  
  
end
