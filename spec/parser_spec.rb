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
    expect(exp.name).to eq('abc')
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

  it 'parses a def! expression into an AssignNode' do
    exp = parse_string('(def! a 42)').body.first

    expect(exp).to be_kind_of(Malady::AST::AssignNode)
    expect(exp.name).to eq('a')
    val = exp.value
    expect(val).to be_kind_of(Malady::AST::IntegerNode)
    expect(val.value).to eq(42)
  end

  it 'parses a nested def! expression' do
    exp = parse_string('(def! a (+ 40 2))').body.first

    expect(exp).to be_kind_of(Malady::AST::AssignNode)
    expect(exp.name).to eq('a')
    val = exp.value
    expect(val).to be_kind_of(Malady::AST::AddNode)
    expect(val.lhs.value).to eq(40)
    expect(val.rhs.value).to eq(2)
  end

  it 'parses a simple let* expression' do
    exp = parse_string('(let* (a 123) a)').body.first

    expect(exp).to be_kind_of(Malady::AST::LetNode)
    sym_val_pair = exp.symbols.first
    expect(sym_val_pair.first).to eql('a')
    expect(sym_val_pair[1]).to be_kind_of(Malady::AST::IntegerNode)
    expect(sym_val_pair[1].value).to eq(123)

    body = exp.body
    expect(body).to be_kind_of(Malady::AST::SymbolNode)
    expect(body.name).to eq('a')
  end

  it 'parses a complicated let* expression' do
    exp = parse_string('(let* (a (+ 20 1) b 2) (* a b))').body.first

    expect(exp).to be_kind_of(Malady::AST::LetNode)
    a = exp.symbols.first
    expect(a.first).to eql('a')
    expect(a[1]).to be_kind_of(Malady::AST::AddNode)

    b = exp.symbols[1]
    expect(b.first).to eql('b')
    expect(b[1]).to be_kind_of(Malady::AST::IntegerNode)
    expect(b[1].value).to eq(2)

    body = exp.body
    expect(body).to be_kind_of(Malady::AST::MultiplyNode)
    expect(body.lhs).to be_kind_of(Malady::AST::SymbolNode)
    expect(body.lhs.name).to eq('a')
    expect(body.rhs).to be_kind_of(Malady::AST::SymbolNode)
    expect(body.rhs.name).to eq('b')
  end
end
