module Malady
  class TokenStream
    attr_reader :pos

    def initialize(tokens)
      @tokens = tokens
      @pos = 0
    end

    def peek
      @tokens[@pos]
    end

    def next
      return nil if @pos >= @tokens.size

      token = @tokens[@pos]
      @pos += 1
      token
    end

    def eof?
      return @pos >= @tokens.size
    end
  end
end
