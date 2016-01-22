require 'spec_helper.rb'
describe Malady::Compiler, '.eval' do
  def eval(string)
    Malady::Compiler.eval(string)
  end

  def eval_with_binding(string, binding)
    Malady::Compiler.eval(string, '(eval)', binding)
  end

  it 'evaluates a simple add expression' do
    expect(eval('(+ 1 2)')).to eql(3)
  end

  it 'evaluates a malady expression' do
    expect(eval('(+ (* 2 3) (* 2 4))')).to eql(14)
  end

  it 'evaluates an integer to itself' do
    expect(eval('42')).to eql(42)
  end

  it 'stores and retrieve a symbol' do
    eval_with_binding('(def! a 40)', Object.send(:binding))
    expect(eval_with_binding('(+ a 2)', Object.send(:binding))).to eql(42)
  end

  it 'evaluates an expression in the context of a let binding' do
    expect(eval('(let* (a (+ 20 1)
                        b 2)
                   (* a b))')).to eql(42)
  end

  it 'evaluates a nested let expresssion' do
    expect(eval('(let* (b 2)
                       (let* (a (+ 20 1))
                             (* a b)))')).to eql(42)
  end

  it 'evaluates a if expression to its then branch when condition is true' do
    expect(eval('(if (< 2 10)
                     42
                     88)')).to eql(42)
  end

  it 'evaluates a if expression to its else branch when condition is false' do
    expect(eval('(if (< 10 2)
                     42
                     88)')).to eql(88)
  end

  it 'evaluates a fn* call' do
    expect(eval('((fn* [x] (* x x)) 8)')).to eql(64)
  end

  it 'evaluates a named function call' do
    malady_fib = <<-malady
    (def! fib (fn* [x]
                (if (< x 2)
                    1
                    (+ (fib (- x 1)) (fib (- x 2))))))
    malady
    eval_with_binding(malady_fib, Object.send(:binding))
    result = eval_with_binding('(fib 8)', Object.send(:binding))
    expect(result).to eql(34)
  end
end
