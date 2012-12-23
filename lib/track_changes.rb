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
        puts "version: #{version_segment.length} #{version_segment.inspect}"
        puts "segment: #{segment.length}"
        
        # Copy over any previous deletes.
        while segment.type == Segment::DELETE do
          new_segments << segment
          segment = @segments.shift
        end
        
        raise MalformedSegments.new if segment.nil?

        # Process the new segment.
        if version_segment.type == Segment::SAME
          if version_segment.length == segment.length
            puts "SAME v=s"
            # No changes.
            new_segments << segment
            segment = @segments.shift
            next
          elsif version_segment.length < segment.length
            puts "SAME v<s"
            # Split the original segment.
            length_diff = segment.length - version_segment.length
            segment.length = version_segment.length  
            new_segments << segment
            segment = Segment.new(segment.type, segment.version, length_diff)
            next
          elsif version_segment.length > segment.length
            puts "SAME v>s"
            # Split the new segment.
            version_segment.length = version_segment.length - segment.length
            # Accumulate the old segment.
            new_segments << segment
            segment = @segments.shift
            # Loop again with the new version segment.
            redo
          end
        elsif version_segment.type == Segment::INSERT
          puts "INSERT"  
          new_segments << version_segment
        elsif version_segment.type == Segment::DELETE
          if version_segment.length == segment.length
            puts "DELETE v=s"  
            new_segments << version_segment
            # Remove the old segment.
            segment = @segments.shift
            next
          elsif version_segment.length < segment.length
            puts "DELETE v<s"  
            # Split the original segment.
            length_diff = segment.length - version_segment.length
            new_segments << version_segment
            segment = Segment.new(segment.type, segment.version, length_diff)
            next
          elsif version_segment.length > segment.length
            puts "DELETE v>s"  
            # Split the new segment.
            version_segment.length = version_segment.length - segment.length
            # Accumulate the old segment.
            new_segments << version_segment
            segment = @segments.shift
            # Loop again with the new version segment.
            redo
          end
        end
      end
      # There should not be any remaining segments
      raise MalformedSegments.new unless @segments.empty?

      @segments = new_segments
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
          result << Segment.new(element[0], to_version, element[1].length, element[1])
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
    SAME = :equal
    DELETE = :delete
    INSERT = :insert
    
    attr_reader :version
    attr_reader :type
    attr_accessor :length
    attr_accessor :deleted_text
    
    def initialize(type, version, length, deleted_text = nil)
      @type, @version, @length, @deleted_text = type, version, length, deleted_text
    end
    
  
  end
end