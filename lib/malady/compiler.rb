module Malady
  class Compiler < RBX::Compiler
    Stages = Hash.new { |h,k| RBX::Compiler::Stages[k] }

    def initialize(from, to)
      @start = Stages[from].new self, to
    end

    def self.eval(code, *args)
      file, line, binding, instance = '(eval)', 1, Object.send(:binding), Object.new
      args.each do |arg|
        case arg
        when String   then file    = arg
        when Integer  then line    = arg
        when Binding  then binding = arg
        else
          instance = arg
        end
      end

      cm       = compile_eval(code, binding.variables, file, line)
      cm.scope = Rubinius::ConstantScope.new(Object)
      cm.name  = :__malady__
      script   = Rubinius::CompiledCode::Script.new(cm, file, true)
      be       = Rubinius::BlockEnvironment.new

      script.eval_source  = code
      cm.scope.script     = script

      be.under_context(binding.variables, cm)
      be.call_on_instance(instance)
    end

    def self.compile_eval(string, variable_scope, file="(eval)", line=1)
      if ec = @eval_cache
        layout = variable_scope.local_layout
        if code = ec.retrieve([string, layout, line])
          return code
        end
      end

      compiler = new :eval, :compiled_code

      parser = compiler.parser
      parser.root RBX::AST::EvalExpression
      parser.default_transforms
      parser.input string, file, line

      compiler.generator.variable_scope = variable_scope

      code = compiler.run

      code.add_metadata :for_eval, true

      if ec and parser.should_cache?
        ec.set([string.dup, layout, line], code)
      end

      return code
    end

    # AST -> Bytecode
    class Bytecode < RBX::Compiler::Bytecode
      Stages[:bytecode] = self
      next_stage RBX::Compiler::Encoder

      def initialize(*)
        super
      ensure
        @processor = Malady::Generator
      end
    end

    # String -> AST
    class StringParser < RBX::Compiler::Parser
      Stages[:string] = self
      next_stage Bytecode

      def initialize(*)
        super
      ensure
        @processor = Malady::Parser.new '(eval)'
      end

      def create
        @parser = @processor
      end

      def input(string, name="(eval)", line=1)
        @input = string
        @file = name
        @line = line
      end

      def parse
        create.parse_string(@input)
      end
    end

    class EvalParser < StringParser
      Stages[:eval] = self
      next_stage Bytecode

      def should_cache?
        @output.should_cache?
      end
    end
  end
end
