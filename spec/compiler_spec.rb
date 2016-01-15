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
end
