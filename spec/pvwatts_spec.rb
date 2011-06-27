require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
describe Pvwatts do
  describe "#yearly_production" do
    it "should fetch the yearly production data" do
      @pdata = Pvwatts.new(PVWATTS_SPEC_KEY).yearly_production(:latitude    => 32.95850, 
                                                :longitude   => -117.12206, 
                                                :dc_rating   => 4.0, 
                                                :tilt        => 45, 
                                                :azimuth => 180,
                                                :derate     => 0.82,
                                                :array_type=>0,
                                                :cost=>0.1)
      @pdata['jan'].should == 496
      @pdata['feb'].should == 469
      @pdata['mar'].should == 539
      @pdata['apr'].should == 525
      @pdata['may'].should == 539
      @pdata['jun'].should == 498
      @pdata['jul'].should == 526
      @pdata['aug'].should == 554
      @pdata['sep'].should == 540
      @pdata['oct'].should == 536
      @pdata['nov'].should == 508
      @pdata['dec'].should == 471
      @pdata['year'].should == 6203
    end
  end
  describe "#get_stats" do
    it "should fetch the stats data" do
      @pdata = Pvwatts.new(PVWATTS_SPEC_KEY).get_stats(:latitude    => 32.95850, 
                                                :longitude   => -117.12206, 
                                                :dc_rating   => 4.0, 
                                                :tilt        => 45, 
                                                :azimuth => 180,
                                                :derate     => 0.82,
                                                :array_type=>0,
                                                :cost=>0.1)
      @pdata.is_a?(Array).should be_true
      @pdata.size.should == 13
      @pdata.each_with_index do |data, i|
        @pdata.is_a?(Hash).should be_true
        if i == 0
          ["array_type","array_tilt","location_id","a_crating","power_degredation","inoct","latitude","d_crating","longitude","currency","electric_cost","array_azimuth","message","d_cto_a_cderate"].each do |key|
            @pdata.has_key?(key).should be_true
          end  
        end
        @pdata["month"].should == month_to_string(i+1)
        (@pdata["a_cenergy"].to_f > 0).should be_true
        (@pdata["cost_saved"].to_f > 0).should be_true
        (@pdata["solar"].to_f > 0).should be_true
      end    
    end
  end
  def month_to_string(integer)
    month_keys={1=>"Jan", 2=>"Feb", 3=>"Mar", 4=>"Apr", 5=>"May", 6=>"Jun", 7=>"Jul", 8=>"Aug", 9=>"Sep", 10=>"Oct", 11=>"Nov", 12=>"Dec", 13=>"Year"}
    month_keys[integer]
  end  
end
