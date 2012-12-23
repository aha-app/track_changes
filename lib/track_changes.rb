require 'diff_match_patch'

module TrackChanges
  
  class MalformedSegments < Exception; end
  
  # TODO: see http://code.google.com/p/google-diff-match-patch/wiki/Plaintext for handling HTML.
  
  class Tracker
    attr_reader :versions
    # Non-overlapping, contiguous, segments in the text, each of which tracks
    # the original of a portion of the text, or a zero-length segment that 
    # tracks the removal of a portion of the text. Stored in position order.
    attr_reader :segments
    
    def initialize
      @versions = []
      @segments = []
    end
    
    def add_version(text, object = nil)
      version = Version.new(text, object)
      accumulate_segments(version)
      @versions << version      
    end
    
  protected
  
    def accumulate_segments(version)
      # First segment?
      if @segments.empty?
        add_same_segment(version)
        return
      end
      
      # Create segments based on diff from previous version.
      version_segments = segments_from_diff(versions.last, version)
      
      # Merge the new segments with the exist set, splitting segments 
      # wherever they overlap and prefering the new segment (since it
      # represents more recent changes).
#      next_orig_seg = next_segment_with_length(nil)
      
      
      new_segments = []
      segment = @segments.shift
      version_segments.each do |version_segment|
        # Copy over any previous deletes.
        while segment.type == Segment::DELETE do
          new_segments << segment
          segment = @segments.shift
        end
        
        raise MalformedSegments.new if segment.nil?

        # Process the new segment.
        if version_segment.type == Segment::SAME
          if version_segment.length == segment.length
          elsif version_segment.length < segment.length
          end
        elsif version_segment.type == Segment::INSERT
          # TODO
        elsif version_segment.type == Segment::DELETE
          # TODO
        end
      end
    end

    # Find the next segment with non-zero length.
    def next_segment_with_length(after_segment)
      found = false
      @segments.each do |segment|
        # Find the segment
        if not found
          if segment == after_segment
            found = true
            next
          end
        else
          return segment if segment.length > 0
        end
      end
      nil
    end

    def add_same_segment(version)
      @segments << Segment.new(Segment::SAME, version, version.text.length)
    end
    
    def segments_from_diff(from_version, to_version)
      differ = DiffMatchPatch.new
      diffs = differ.diff_main(from_version.text, to_version.text, false)
      differ.diff_cleanupSemantic(diffs)
      puts diffs.inspect
      
      segments = diffs.inject([]) do |result, element|
        if element[0] == :delete
          result << Segment.new(element[0], to_version, 0, element[1])
        else
          result << Segment.new(element[0], to_version, element[1].length)
        end
        result
      end
    end
    
  end
  
  class Version
    attr_reader :object
    attr_reader :text
    
    def initialize(text, object = nil)
      @text, @object = text, object
    end
  end
  
  class Segment
    SAME = :same
    DELETE = :delete
    INSERT = :insert
    
    attr_reader :version
    attr_reader :type, :length
    attr_reader :deleted_text
    
    def initialize(type, version, length, deleted_text = nil)
      @type, @version, @length, @deleted_text = type, version, length, deleted_text
    end
    
  
  end
end