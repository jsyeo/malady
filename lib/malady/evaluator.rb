module Malady
  module Evaluator
    module_function
    def evaluate(env, ast)
      type = ast.first
      rest = ast[1..-1]
      if type == :list
        evaluated_list = eval_ast(env, ast)
        fn = evaluated_list[1]
        args = evaluated_list[2..-1]
        fn.call(*args)
      else
        eval_ast(env, ast)
      end
    end

    def eval_with_repl_env(ast)
      repl_env = {
        '+' => lambda { |x, y| x + y },
        '-' => lambda { |x, y| x - y },
        '/' => lambda { |x, y| Integer(x / y) },
        '*' => lambda { |x, y| x * y }
      }
      evaluate(repl_env, ast)
    end

    def eval_ast(env, ast)
      type = ast.first
      rest = ast[1..-1]
      case type
      when :symbol
        env[ast[1]]
      when :list
        result = [:list]
        result + rest.map { |ast| evaluate(env, ast) }
      when :integer
        ast[1]
      else
        ast
      end
    end
  end
end
