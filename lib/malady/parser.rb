module Malady
  class Parser
    attr_reader :filename

    def initialize(filename)
      @filename = filename
      @line = 0
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
        when 'if'
          parse_if(sexp)
        when 'fn*'
          parse_fn(sexp)
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
      when :boolean
        boolean = sexp.last
        if boolean == :true
          Malady::AST::TrueBooleanNode.new(@filename, @line)
        else
          Malady::AST::FalseBooleanNode.new(@filename, @line)
        end
      when :symbol
        name = sexp.last
        builtins.fetch(name, Malady::AST::SymbolNode.new(@filename, @line, name))
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

    def parse_if(sexp)
      # [:list, [:symbol, 'if'], condition, then_branch, else_branch]
      _, _, condition, then_branch, else_branch = sexp
      Malady::AST::IfNode.new(@filename, @line, parse(condition), parse(then_branch), parse(else_branch))
    end

    def parse_fn(sexp)
      # [:list, [:symbol, 'fn*'], [:list, [:symbol, 'x']], body]
      _, _, (_, *arguments), body = sexp
      arguments = arguments.map(&:last)
      Malady::AST::FnNode.new(@filename, @line, arguments, parse(body))
    end

    def apply(fn, args)
      if builtins.values.include? fn
        fn.new(@filename, @line, *args)
      else
        Malady::AST::FunctionCallNode.new(@filename, @line, fn, args)
      end
    end

    def builtins
      {
        '+' => Malady::AST::AddNode,
        '-' => Malady::AST::MinusNode,
        '/' => Malady::AST::DivideNode,
        '*' => Malady::AST::MultiplyNode,
        '<' => Malady::AST::LessThanNode,
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
