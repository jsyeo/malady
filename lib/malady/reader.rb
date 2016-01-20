module Malady
  module Reader
    module_function
    def parse_string(string)
      read_str(string)
    end

    def read_str(string)
      tokens = tokenizer(string)
      stream = Malady::TokenStream.new(tokens)
      read_form(stream)
    end

    def read_form(stream)
      if stream.peek == '('
        read_list(stream)
      else
        read_atom(stream.next)
      end
    end

    def read_list(stream)
      raise 'Reader error: read_list called on non-list' if stream.next != '('
      list = [:list]

      while stream.peek != ')'
        raise 'Reader error: Unmatched parens' if stream.eof?
        list << read_form(stream)
      end

      stream.next # pop our closing paren

      list
    end

    def read_atom(token)
      case token
      when /^-?\d+$/
        [:integer, token.to_i]
      when 'true'
        [:boolean, :true]
      when 'false'
        [:boolean, :false]
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
