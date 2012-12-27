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
      @chars = {}
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
      @chars.each do |char, tag|
        html.gsub!(char, tag)
      end
      html
    end
    
  protected
  
    def push(tag)
      if @tags[tag]
        @tags[tag]
      else
        char = [@currentHash].pack('U*')
        @tags[tag] = char
        @chars[char] = tag
        @currentHash += 1
        char
      end
    end
    
  end
  
end