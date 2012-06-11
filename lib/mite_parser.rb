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
    input = to_shellwords(input.dup)
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
  
  def to_shellwords(str)
    return str unless str.is_a?(String)
    
    Shellwords.shellwords(str)
  rescue ArgumentError => e    
    case e.message
    when /^Unmatched (single|double) quote: (.+)/
      if str.split(/'/).size == 2
        str.sub!(/'/, "___SINGLE_QUOTE___")
      end
      
      Shellwords.shellwords(str).map do |word|
        word.gsub("___SINGLE_QUOTE___", "'")
      end
    end
  end
end