$: << File.join(File.dirname(__FILE__), '..', 'lib')
require 'rubygems'
require 'spec'
require 'mite_parser'

describe MiteParser do
  
  before do
    @parser = MiteParser.define do
      add :project
      add :service, :leistung
      add
    end
  end
  
  it "should define new parser" do
    @parser.is_a?(MiteParser).should be_true
  end
  
  it "should give back all as unclaimed when no flag used" do
    @parser.parse("project Projektname").should == ({:unclaimed => %w(project Projektname)})
  end
  
  it "should give back project name when parsing string" do
    @parser.parse("#project Projektname")[:project].should eql("Projektname")
  end
  
  it "should give back project name when parsing array" do
    @parser.parse(%w(BlaBla #project Projektname2))[:project].should eql("Projektname2")
  end
  
  it "should allow multiple flags" do
    @parser.parse("#project Projektname #service MyService").should == ({:project => "Projektname", :service => "MyService"})
  end
  
  it "should allow short flags" do
    @parser.parse("#p Projektname #s MyService").should == ({:project => "Projektname", :service => "MyService"})
  end
  
  it "should allow flag-values with brackets" do
    @parser.parse("#project 'Projekt name' #service MyService").should == ({:project => "Projekt name", :service => "MyService"})
    @parser.parse("#project \"Projekt name\" #service MyService").should == ({:project => "Projekt name", :service => "MyService"})
  end
  
  it "should allow partial flags" do
    @parser.parse("#proje Projektname #ser MyService").should == ({:project => "Projektname", :service => "MyService"})
  end
  
  it "should ignore case flags" do
    @parser.parse("#P Projektname #SERVICE MyService").should == ({:project => "Projektname", :service => "MyService"})
  end
  
  it "should allow alias flags" do
    @parser.parse("#l MyLeistung").should == ({:service => "MyLeistung"})
    @parser.parse("#Lei MyLeistung").should == ({:service => "MyLeistung"})
    @parser.parse("#leistung MyLeistung").should == ({:service => "MyLeistung"})
  end
  
  it "should set flags as keys when empty" do
    @parser.parse("#P #SERVICE MyService").should == ({:project => nil, :service => "MyService"})
    @parser.parse("#P MyService #SERVICE").should == ({:project => "MyService", :service => nil})
  end
  
  it "should give back all unclaimed" do
    @parser.parse("null vorn #p P erstes un #s S zweites u").should == ({
      :unclaimed => %w(null vorn erstes un zweites u),:project => "P", :service => "S"
    })
  end
  
  it "should allow single quote in double quotes" do
    @parser.parse("#p \"Toy\'s for us\"").should == ({:project => "Toy's for us"})
    @parser.parse("#p \"Toy's for us\"").should == ({:project => "Toy's for us"})
    @parser.parse("#p \"Toy's'for us\"").should == ({:project => "Toy's'for us"})
  end
  
  it "should allow double quote in single quotes" do
    @parser.parse("#p 'Toy\"s for us'").should == ({:project => "Toy\"s for us"})
    @parser.parse("#p 'Toy\"s\"for us'").should == ({:project => "Toy\"s\"for us"})
  end
  
  it "should autocorrect unclosed single quote" do
    @parser.parse("#p 'Toy s for us").should == ({:project => "Toy", :unclaimed => %w(s for us)})
    @parser.parse("#p 'Toy s for #l us").should == ({:project => "Toy", :unclaimed => %w(s for), :service => "us"})
    @parser.parse("#p Toy's for us").should == ({:project => "Toys", :unclaimed => %w(for us)})
  end
  
  it "should autocorrect unclosed double quote" do
    @parser.parse("#p \"Toy s for us").should == ({:project => "Toy", :unclaimed => %w(s for us)})
    @parser.parse("#p \"Toy s for #l us").should == ({:project => "Toy", :unclaimed => %w(s for), :service => "us"})
    @parser.parse("#p Toy\"s for us").should == ({:project => "Toys", :unclaimed => %w(for us)})
  end
end
