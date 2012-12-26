module TrackChanges
  
  #
  # Replace HTML tags with single characters so that diffing the HTML
  # does not result in corrupted tags.
  #
  # This does not handle issues with unclosed tags, or tags that overlap.
  #
  # Based on the aglorithm here: http://code.google.com/p/google-diff-match-patch/wiki/Plaintext
  #
  class CollapseHtml
    
    def initialize
      @tags = {}
      @currentHash = 44032; # Hangul Syllables
    end
    
    #
    # Replace HTML tags and return a string.
    #
    def collapse(html)
      html.gsub(/<[^>]*>|<[^>]*\/>|<\/[^>]*>|&[^;]+;/) do |tag|
        push(tag)
      end
    end
    
    #
    # Reinstate the HTML tags in the string
    #
    def expand(text)
      html = text
      @tags.each do |char, tag|
        html.gsub!(char, tag)
      end
      html
    end
    
  protected
  
    def push(tag)
      char = [@currentHash].pack('U*')
      @tags[char] = tag
      @currentHash += 1
      char
    end
    
  end
  
end