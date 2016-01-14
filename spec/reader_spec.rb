require 'spec_helper'

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
    expect(read_str('(+ (* 2 3) (* 4 5))')).to eq(
      [:list,
       [:symbol, '+'],
       [:list,
        [:symbol, '*'],
        [:integer, 2],
        [:integer, 3]],
       [:list,
        [:symbol, '*'],
        [:integer, 4],
        [:integer, 5]]]
    )
  end
end


