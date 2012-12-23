require 'spec_helper'

describe TrackChanges do
  before do
    @tracker = TrackChanges::Tracker.new
  end

  context "accumulates changes" do
    
    it "can add multiple versions" do
      @tracker.add_version("text body")
      @tracker.add_version("text 1 body")
      @tracker.add_version("text 2 body")
      @tracker.versions.count.should == 3
    end
    
    it "can track object with versions" do
      @tracker.add_version("text body", {})
      @tracker.add_version("text 1 body", 33)
      
      @tracker.versions.first.object.should == {}
      @tracker.versions.last.object.should == 33
    end
  end
  
  context "segments changes" do
    
    it "can segment changes" do
      @tracker.add_version("text body")
      @tracker.add_version("text 1 body")
      @tracker.add_version("text 2 body")
      @tracker.segments.count.should == 5
    end
    
  end
end