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
      @tracker.segments.count.should == 3
      @tracker.segments[0].type.should == TrackChanges::Segment::SAME
      @tracker.segments[0].length.should == 5
      @tracker.segments[1].type.should == TrackChanges::Segment::INSERT
      @tracker.segments[1].length.should == 2
      @tracker.segments[2].type.should == TrackChanges::Segment::SAME
      @tracker.segments[2].length.should == 4
    end
    
    it "can segment changes" do
      @tracker.add_version("text body")
      @tracker.add_version("text 1 body")
      @tracker.add_version("text 2 body")
      @tracker.segments.count.should == 5
      @tracker.segments[0].type.should == TrackChanges::Segment::SAME
      @tracker.segments[0].length.should == 5
      @tracker.segments[1].type.should == TrackChanges::Segment::DELETE
      @tracker.segments[1].length.should == 1
      @tracker.segments[2].type.should == TrackChanges::Segment::INSERT
      @tracker.segments[2].length.should == 1
      @tracker.segments[3].type.should == TrackChanges::Segment::INSERT
      @tracker.segments[3].length.should == 1
      @tracker.segments[4].type.should == TrackChanges::Segment::SAME
      @tracker.segments[4].length.should == 4
    end
    
    it "can segment changes" do
      @tracker.add_version("text body")
      @tracker.add_version("text ody")
      @tracker.add_version("text ")
      @tracker.segments.count.should == 3
      @tracker.segments[0].type.should == TrackChanges::Segment::SAME
      @tracker.segments[0].length.should == 5
      @tracker.segments[1].type.should == TrackChanges::Segment::DELETE
      @tracker.segments[1].length.should == 1
      @tracker.segments[2].type.should == TrackChanges::Segment::DELETE
      @tracker.segments[2].length.should == 3
    end
 
    it "can segment changes" do
      @tracker.add_version("text body")
      @tracker.add_version("body")
      @tracker.add_version("body 1")
      @tracker.segments.count.should == 3
      @tracker.segments[0].type.should == TrackChanges::Segment::DELETE
      @tracker.segments[0].length.should == 5
      @tracker.segments[1].type.should == TrackChanges::Segment::SAME
      @tracker.segments[1].length.should == 4
      @tracker.segments[2].type.should == TrackChanges::Segment::INSERT
      @tracker.segments[2].length.should == 2
    end
   
    it "can segment changes" do
      @tracker.add_version("text")
      @tracker.add_version("text 1")
      @tracker.add_version("text 1 2")
      @tracker.add_version("text")
      @tracker.segments.count.should == 3
      @tracker.segments[0].type.should == TrackChanges::Segment::SAME
      @tracker.segments[0].length.should == 4
      @tracker.segments[1].type.should == TrackChanges::Segment::DELETE
      @tracker.segments[1].length.should == 2
      @tracker.segments[2].type.should == TrackChanges::Segment::DELETE
      @tracker.segments[2].length.should == 2
    end

  end
end