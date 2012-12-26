#!/bin/env ruby
# encoding: utf-8

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
      @tracker.add_version("text body", 1)
      @tracker.add_version("text 1 body", 2)
      @tracker.segments.count.should == 3
      @tracker.segments[0].type.should == TrackChanges::Segment::SAME
      @tracker.segments[0].length.should == 5
      @tracker.segments[1].type.should == TrackChanges::Segment::INSERT
      @tracker.segments[1].length.should == 2
      @tracker.segments[2].type.should == TrackChanges::Segment::SAME
      @tracker.segments[2].length.should == 4
      @tracker.to_s.should == "SAME:text :1,INSERT:1 :2,SAME:body:1"
    end
    
    it "can segment changes" do
      @tracker.add_version("text body", 1)
      @tracker.add_version("text 1 body", 2)
      @tracker.add_version("text 2 body", 3)
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
      @tracker.to_s.should == "SAME:text :1,DELETE:1:3,INSERT:2:3,INSERT: :2,SAME:body:1"
    end
    
    it "can segment changes" do
      @tracker.add_version("text body", 1)
      @tracker.add_version("text ody", 2)
      @tracker.add_version("text ", 3)
      @tracker.segments.count.should == 3
      @tracker.segments[0].type.should == TrackChanges::Segment::SAME
      @tracker.segments[0].length.should == 5
      @tracker.segments[1].type.should == TrackChanges::Segment::DELETE
      @tracker.segments[1].length.should == 1
      @tracker.segments[2].type.should == TrackChanges::Segment::DELETE
      @tracker.segments[2].length.should == 3
      @tracker.to_s.should == "SAME:text :1,DELETE:b:2,DELETE:ody:3"
    end
 
    it "can segment changes" do
      @tracker.add_version("text body", 1)
      @tracker.add_version("body", 2)
      @tracker.add_version("body 1", 3)
      @tracker.segments.count.should == 3
      @tracker.segments[0].type.should == TrackChanges::Segment::DELETE
      @tracker.segments[0].length.should == 5
      @tracker.segments[1].type.should == TrackChanges::Segment::SAME
      @tracker.segments[1].length.should == 4
      @tracker.segments[2].type.should == TrackChanges::Segment::INSERT
      @tracker.segments[2].length.should == 2
      @tracker.to_s.should == "DELETE:text :2,SAME:body:1,INSERT: 1:3"
    end
   
    it "can segment changes" do
      @tracker.add_version("text", 1)
      @tracker.add_version("text 1", 2)
      @tracker.add_version("text 1 2", 3)
      @tracker.add_version("text", 4)
      @tracker.segments.count.should == 3
      @tracker.segments[0].type.should == TrackChanges::Segment::SAME
      @tracker.segments[0].length.should == 4
      @tracker.segments[1].type.should == TrackChanges::Segment::DELETE
      @tracker.segments[1].length.should == 2
      @tracker.segments[2].type.should == TrackChanges::Segment::DELETE
      @tracker.segments[2].length.should == 2
      @tracker.to_s.should == "SAME:text:1,DELETE: 1:4,DELETE: 2:4"
    end

    it "can handle corner cases" do
      @tracker.add_version("text", 1)
      @tracker.add_version("", 2)
      @tracker.segments.count.should == 1
      @tracker.segments[0].type.should == TrackChanges::Segment::DELETE
      @tracker.segments[0].length.should == 4
      @tracker.to_s.should == "DELETE:text:2"
    end

    it "can handle corner cases" do
      @tracker.add_version("", 1)
      @tracker.add_version("text", 2)
      @tracker.segments.count.should == 1
      @tracker.segments[0].type.should == TrackChanges::Segment::INSERT
      @tracker.segments[0].length.should == 4
      @tracker.to_s.should == "INSERT:text:2"
    end

    it "can handle corner cases" do
      @tracker.add_version("text", 1)
      @tracker.add_version("body", 2)
      @tracker.segments.count.should == 2
      @tracker.segments[0].type.should == TrackChanges::Segment::DELETE
      @tracker.segments[0].length.should == 4
      @tracker.segments[1].type.should == TrackChanges::Segment::INSERT
      @tracker.segments[1].length.should == 4
      @tracker.to_s.should == "DELETE:text:2,INSERT:body:2"
    end

  end
  
  context "collapses html" do
    before do
      @collapser = TrackChanges::CollapseHtml.new
    end
    
    it "can collapse html" do
      @collapser.collapse("<a>bcd</a>").should == "가bcd각"
    end

    it "can expand html" do
      @collapser.expand(@collapser.collapse("<a>bcd</a>")).should == "<a>bcd</a>"
    end
    
    it "html corner cases" do
      @collapser.collapse("<a>bc<b/>d</a>eded<a></a>").should == "가bc각d갂eded갃간"
    end
    
    it "can collapse html entities" do
      @collapser.collapse("<a>bc&nbsp;d</a>").should == "가bc각d갂"
    end
    
    it "can handle html entities" do
      @collapser.collapse("<a>bc&nbsp;d</a>").should == "가bc각d갂"
      @collapser.expand(@collapser.collapse("<a>bc&nbsp;d</a>")).should == "<a>bc&nbsp;d</a>"
    end
  end
end