module Malady
  module Reader
    module_function
    def parse_string(string)
      read_str(string)
    end

    def read_str(string)
      tokens = tokenizer(string)
      read_form(tokens)
    end

    def read_form(tokens)
      if tokens.first =~ /(\(|\[)/
        read_list(tokens)
      else
        read_atom(tokens.shift)
      end
    end

    def read_list(tokens)
      raise 'Reader error: read_list called on non-list' if tokens.shift !~ /(\(|\[)/
      list = [:list]

      while tokens.first !~ /(\)|\])/
        raise 'Reader error: Unmatched parens' if tokens.empty?
        list << read_form(tokens)
      end

      tokens.shift # pop our closing paren

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
