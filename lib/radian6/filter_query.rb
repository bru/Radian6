module Radian6
  class FilterQuery
    attr_accessor :query, :isExcludeQuery, :id
    
    def initialize(params)
      params = {} unless params.is_a? Hash
      @isExcludeQuery = params[:isExcludeQuery] || ''
      @query   = params[:query] || ''
      @id       = params[:id] || ''
    end
  end
end
