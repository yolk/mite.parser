require 'shellwords'
require File.dirname(__FILE__) + '/mite_parser/option'

class MiteParser
  
  OPTION_FLAG = %r(^#([a-zA-Z]+)$)
  
  def initialize
    @options = []
  end
  
  def self.define(&block)
    parser = self.new
    parser.instance_eval(&block)
    parser
  end
  
  def add(*names)
    return if names.size == 0
    @options << Option.new(names)
  end
  
  def parse(input)
    input = input.is_a?(String) ? Shellwords.shellwords(input) : input.dup
    output = {}
    
    while token = input.shift
      option_name = token.scan(MiteParser::OPTION_FLAG).flatten[0]
      
      if option = find_option(option_name)
        output[option.name.to_sym] = input[0] && !input[0].match(MiteParser::OPTION_FLAG) ? input.shift : nil
      else
        (output[:unclaimed] ||= []) << token
      end
    end
    
    output
  end
  
  private
  
  def find_option(name)
    return unless name 
    
    @options.find do |opt|
      opt.has?(name)
    end
  end
end