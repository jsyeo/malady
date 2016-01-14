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
      type = sexp.first
      rest = sexp[1..-1]
      if type == :list
        parsed_list = parse_sexp(sexp)
        fn = parsed_list.first
        args = parsed_list[1..-1]
        fn.new(@filename, @line, *args)
      else
        parse_sexp(sexp)
      end
    end

    def parse_sexp(sexp)
      type = sexp.first
      rest = sexp[1..-1]
      case type
      when :symbol
        @symbols[sexp[1]]
      when :integer
        Malady::AST::IntegerNode.new @filename, @line, sexp[1]
      when :list
        rest.map { |sexp| parse(sexp) }
      end
    end

    def builtins
      {
        '+' => Malady::AST::AddNode,
        '-' => Malady::AST::MinusNode,
        '/' => Malady::AST::DivideNode,
        '*' => Malady::AST::MultiplyNode
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
