require 'spec_helper.rb'
describe Malady::Parser, '.parse_string' do
  def parse_string(string)
    Malady::Parser.new('(eval)').parse_string(string)
  end

  it 'parses a simple add expression and returns Malady AST nodes' do
    exp = parse_string('(+ 4 2)').body.first

    expect(exp).to be_kind_of(Malady::AST::AddNode)
    expect(exp.lhs.value).to eq(4)
    expect(exp.rhs.value).to eq(2)
  end

  it 'parses an integer into an integer AST node' do
    exp = parse_string('42').body.first

    expect(exp).to be_kind_of(Malady::AST::IntegerNode)
    expect(exp.value).to eq(42)
  end

  it 'parses a symbol into a symbol AST node' do
    exp = parse_string('abc').body.first

    expect(exp).to be_kind_of(Malady::AST::SymbolNode)
    expect(exp.value).to eq('abc')
  end

  it 'parses a complex nested expression into Malady AST nodes' do
    exp = parse_string('(+ (* 2 4) (* 2 5))').body.first

    expect(exp).to be_kind_of(Malady::AST::AddNode)
    lhs = exp.lhs
    rhs = exp.rhs

    expect(lhs).to be_kind_of(Malady::AST::MultiplyNode)
    expect(lhs.lhs.value).to eq(2)
    expect(lhs.rhs.value).to eq(4)

    expect(rhs).to be_kind_of(Malady::AST::MultiplyNode)
    expect(rhs.lhs.value).to eq(2)
    expect(rhs.rhs.value).to eq(5)
  end
end
