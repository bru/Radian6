module Radian6
  class FilterGroup
    attr_accessor :name, :queries, :id
    
    def initialize(params)
      params = {} unless params.is_a? Hash
      @name = params[:name] || ''
      @queries   = params[:queries] || ''
      @id       = params[:id] || ''
    end
  end
end
