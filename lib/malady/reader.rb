module Malady
  class Reader
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

    class << self
      def read_str(string)
        tokens = tokenizer(string)
        reader = Reader.new(tokens)
        read_form(reader)
      end

      def read_form(reader)
        if reader.peek == '('
          read_list(reader)
        else
          read_atom(reader)
        end
      end

      def read_list(reader)
        raise 'Reader error: read_list called on non-list' if reader.next != '('
        list = [:list]
        while reader.peek != ')'
          raise 'Reader error: Unmatched parens' if reader.eof?
          list << read_form(reader)
        end
        list
      end

      def read_atom(reader)
        token = reader.next
        case token
        when /^-?\d+$/
          [:integer, token.to_i]
        when /^\D+$/
          [:symbol, token]
        else
          raise 'Reader error: Unknown token'
        end
      end

      def tokenizer(string)
        pos = 0
        re = /[\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"|;.*|[^\s\[\]{}('"`,;)]*)/
        result = []
        while (m = re.match(string, pos)) && pos < string.size
          result << m.to_s.strip
          pos = m.end(0)
        end
        result
      end
    end
  end
end
