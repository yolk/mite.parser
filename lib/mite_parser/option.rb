class MiteParser
  class Option
    
    def initialize(names)
      @names = [names].flatten.map{|name| name.to_s}
    end
    
    def name
      @names[0]
    end
    
    def has?(term)
      @names.find{|name| name.match(%r(^#{term.downcase}))}
    end
    
  end
end