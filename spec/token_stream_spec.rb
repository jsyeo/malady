require 'spec_helper'

describe Malady::TokenStream, '#peek' do
  it 'returns the token at the current position' do
    string = '(+ 3 3)'
    tokens = Malady::Reader.tokenizer(string)
    expect(Malady::TokenStream.new(tokens).peek).to eq('(')
  end
end

describe Malady::TokenStream, '#next' do
  let(:tokens) { ['(', '+', '3', '3', ')'] }

  it 'returns the next token' do
    expect(Malady::TokenStream.new(tokens).next).to eq('(')
  end

  it 'increments the position' do
    stream = Malady::TokenStream.new(tokens)
    pos = stream.pos
    stream.next
    expect(stream.pos).to eq(pos + 1)
  end

  it 'returns nil when there are no more tokens' do
    stream = Malady::TokenStream.new(['123'])
    stream.next
    expect(stream.next).to be_nil
  end
end


