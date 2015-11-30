require 'spec_helper.rb'
describe Malady::Evaluator, '.evaluate' do
  let(:repl_env) do
    {
      '+' => lambda { |x, y| x + y },
      '-' => lambda { |x, y| x - y },
      '/' => lambda { |x, y| Integer(x / y) },
      '*' => lambda { |x, y| x * y }
    }
  end

  def evaluate(env, ast)
    Malady::Evaluator.evaluate(env, ast)
  end

  it 'evaluates a simple add expression' do
    add_ast = [:list,
               [:symbol, '+'],
               [:integer, 3],
               [:integer, 3]]
    expect(evaluate(repl_env, add_ast)).to eql(6)
  end

  it 'evaluates a nested expression' do
    nested_ast = [:list,
                  [:symbol, '+'],
                  [:integer, 3],
                  [:list,
                   [:symbol, '*'],
                   [:integer, 4],
                   [:integer, 5]]]
    expect(evaluate(repl_env, nested_ast)).to eql(23)
  end

end

