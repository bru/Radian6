module Radian6
  class FilterQuery
    attr_accessor :query, :isExcludeQuery, :id
    
    def initialize(params)
      @isExcludeQuery = params[:isExcludeQuery]
      @query   = params[:query]
      @id       = params[:id]
    end
  end
end
