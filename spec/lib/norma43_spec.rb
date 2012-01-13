require 'spec_helper'
require 'lib/norma43'
 
describe Norma43 do
 
  describe "parse" do
    
    before :each do
      @data = Norma43.read(File.join(File.dirname(__FILE__), "..", "data", "test.n43"))
    end
    
    specify { @data[:movements].size.should == 10 }
    specify { @data[:info][:initial_balance].should == 10593.16 }
    specify { @data[:info][:final_balance].should == 4469.33 }
    
    #initial_balance + movements should be final balance. Float comparison with be_within
    specify { (@data[:info][:initial_balance] + @data[:movements].inject( 0 ) { |sum,x| sum+x[:amount] }).should be_within(0.1).of(@data[:info][:final_balance]) }

    
  end
  
end