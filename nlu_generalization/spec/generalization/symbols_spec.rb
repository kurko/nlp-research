require "spec_helper"

RSpec.describe NLU::Generalization::Symbols do

  describe "token_length" do
    subject do
      symbols = described_class.new
      symbols.add(type: 't', symbol: 'i')
      symbols.add(type: 't', symbol: '[type:subject] want a [type:car]')
      symbols.add(type: 't', symbol: '[type:unknown:wat wat] wat')
      symbols.add(type: 't', symbol: '[type:subject] want')
      symbols.add(type: 't', symbol: 'i want')
      symbols.add(type: 't', symbol: 'ford')
      symbols.add(type: 't', parse_rule: /I want a car/)
      symbols.add(type: 't', parse_rule: /my.gm\saston martin/)
      symbols.add(type: 't', parse_rule: /(gm|ford|chevrolet|abc)/)
    end

    it "returns how lengthy the combinations need to be to match symbols" do
      base = subject.base.map do |symbol|
        parse_rule = symbol[:symbol] || symbol[:parse_rule]
        {
          token_length: symbol[:token_length],
          rule: parse_rule
        }
      end

      expect(base).to eq([
        { token_length: 1, rule: "i" },
        { token_length: 4, rule: "[type:subject] want a [type:car]" },
        { token_length: 2, rule: "[type:unknown:wat wat] wat" },
        { token_length: 2, rule: "[type:subject] want" },
        { token_length: 2, rule: "i want" },
        { token_length: 1, rule: "ford" },
        { token_length: 4, rule: /I want a car/ },
        { token_length: 3, rule: /my.gm\saston martin/ },
        { token_length: 1, rule: /(gm|ford|chevrolet|abc)/ },
      ])
    end
  end
end
