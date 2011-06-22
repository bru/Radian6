module Radian6
  class FilterGroup
    attr_accessor :name, :queries, :id
    
    def initialize(params)
      @name = params[:name]
      @queries   = params[:queries]
      @id       = params[:id]
    end
  end
end
