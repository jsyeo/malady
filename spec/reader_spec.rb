require 'spec_helper'

describe Malady::Reader, '#peek' do
  it 'returns the token at the current position' do
    string = '(+ 3 3)'
    tokens = Malady::Reader.tokenizer(string)
    expect(Malady::Reader.new(tokens).peek).to eq('(')
  end
end

describe Malady::Reader, '#next' do
  let(:tokens) { ['(', '+', '3', '3', ')'] }

  it 'returns the next token' do
    expect(Malady::Reader.new(tokens).next).to eq('(')
  end

  it 'increments the position' do
    reader = Malady::Reader.new(tokens)
    pos = reader.pos
    reader.next
    expect(reader.pos).to eq(pos + 1)
  end

  it 'returns nil when there are no more tokens' do
    reader = Malady::Reader.new(['123'])
    reader.next
    expect(reader.next).to be_nil
  end
end

describe Malady::Reader, '.tokenizer' do
  def tokenize(string)
    Malady::Reader.tokenizer(string)
  end

  it 'tokenizes an integer' do
    expect(tokenize('23')).to eq(['23'])
  end

  it 'tokenizes a symbol' do
    expect(tokenize('abc')).to eq(['abc'])
  end

  it 'tokenizes a simple add expression' do
    expect(tokenize('(+ 3 3)')).to eq(['(', '+', '3', '3', ')'])
  end

  it 'tokenizes a nested expression' do
    expect(tokenize('(+ 3 (* 4 5))')).to eq(['(', '+', '3', '(', '*', '4', '5', ')', ')'])
  end
end

describe Malady::Reader, '.read_str' do
  def read_str(string)
    Malady::Reader.read_str(string)
  end

  it 'converts an expression into mal data structures' do
    expect(read_str('(+ 3 3)')).to eq(
      [:list,
       [:symbol, '+'],
       [:integer, 3],
       [:integer, 3]]
    )
  end

  it 'converts a symbol' do
    expect(read_str('abc')).to eq([:symbol, 'abc'])
  end

  it 'converts an integer' do
    expect(read_str('42')).to eq([:integer, 42])
  end

  it 'tokenizes a nested expression' do
    expect(read_str('(+ 3 (* 4 5))')).to eq(
      [:list,
       [:symbol, '+'],
       [:integer, 3],
       [:list,
        [:symbol, '*'],
        [:integer, 4],
        [:integer, 5]]]
    )
  end
end

