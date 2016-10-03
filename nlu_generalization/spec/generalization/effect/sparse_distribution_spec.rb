require "spec_helper"

RSpec.describe NLU::Generalization::Effect, "Sparse distribution" do
  subject { described_class.new(cause: cause, learned: learned, symbols: symbols) }

  before do
    $nlu_debug = false
  end

  describe "#calculate" do
    context "single distribution 'sentence + [type]'" do
      let(:symbols) do
        symbols = NLU::Generalization::Symbols.new
        symbols.add(type: 'make',  symbol: 'gm')
        symbols.add(type: 'make',  symbol: 'ford')
        symbols.add(type: 'model', symbol: 'focus')
        symbols.add(type: 'car',   symbol: '[type:make] [type:model]')
        symbols.add(type: 'year',  parse_rule: /[0-9]{4}/)
      end

      let(:learned) do
        generalization = NLU::Generalization.new(symbols: symbols)
        generalization.teach(cause: 'eu quero um ford focus', effect: :search_car)
        generalization.learned
      end

      let(:cause) { "eu quero um ford focus" }

      it "matches anything in that position" do
        ap learned
        expect(subject.calculate).to eq([{
          fn: :search_car,
          attrs: {
            make:  "ford",
            model: "focus",
          },
          score: 2.0
        }])
      end
    end
  end
end
