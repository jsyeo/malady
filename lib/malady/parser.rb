module Malady
  class Parser
    attr_reader :filename

    def initialize(filename)
      @filename = filename
      @line = 0
      @symbols = Hash.new do |hash, key|
        Malady::AST::SymbolNode.new @filename, @line, key
      end
      @symbols = @symbols.merge builtins
    end

    def parse_string(string)
      sexp = Reader.read_str(string)
      program_body = [parse(sexp)]
      Malady::AST::Program.new @filename, @line, program_body
    end

    def parse(sexp)
      type, *rest = sexp
      if type == :list
        symbol = rest.first
        case symbol[1]
        when 'def!'
          parse_def(sexp)
        when 'let*'
          parse_let(sexp)
        else
          fn, *args = parse_sexp(sexp)
          apply(fn, args)
        end
      else
        parse_sexp(sexp)
      end
    end

    def parse_sexp(sexp)
      type, *rest = sexp
      case type
      when :symbol
        @symbols[sexp[1]]
      when :integer
        Malady::AST::IntegerNode.new @filename, @line, sexp[1]
      when :list
        rest.map { |sexp| parse(sexp) }
      end
    end

    def parse_def(sexp)
      # [:list, [:symbol, 'def!'], [:symbol, 'blah'], sexp]
      name = sexp[2][1]
      value = sexp[3]
      Malady::AST::AssignNode.new(@filename, @line, name, parse(value))
    end

    def parse_let(sexp)
      # [:list, [:symbol, 'let'], [:list, [:symbol, 'c'], sexp], sexp]
      bindings = sexp[2][1..-1].each_slice(2).to_a
      body = sexp[3]
      parsed_bindings = bindings.map { |s, val| [s[1], parse(val)] }
      Malady::AST::LetNode.new(@filename, @line, parsed_bindings, parse(body))
    end

    def apply(fn, args)
      fn.new(@filename, @line, *args)
    end

    def builtins
      {
        '+' => Malady::AST::AddNode,
        '-' => Malady::AST::MinusNode,
        '/' => Malady::AST::DivideNode,
        '*' => Malady::AST::MultiplyNode,
      }
    end

    # the following methods are needed to conform with RBX's parser interface
    def pre_exe
      []
    end

    def on_error(t, val, vstack)
        raise ParseError, sprintf("\nparse error on value %s (%s) #{@filename}:#{@line}",
            val.inspect, token_to_str(t) || '?')
    end
  end
end
