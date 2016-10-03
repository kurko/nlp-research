require "spec_helper"

RSpec.describe NLU::Generalization::TypedString, "Composite" do
  subject { described_class.new(symbols) }

  before do
    $nlu_debug = false
  end

  describe "#is_a" do
    context 'multi-level hierarchical symbols' do
      let(:symbols) do
        symbols = NLU::Generalization::Symbols.new
        symbols.add(type: 'make',    symbol: 'ford')
        symbols.add(type: 'make',    symbol: 'gm')
        symbols.add(type: 'model',   symbol: 'focus')
        symbols.add(type: 'model',   symbol: 'cruze')
        symbols.add(type: 'number',  parse_rule: /[0-9]+/)
        symbols.add(type: 'cc',      parse_rule: '[type:number].[type:number]')
        symbols.add(type: 'car',     parse_rule: '[type:make]')
        symbols.add(type: 'car',     parse_rule: '[type:make] [type:model]')
        symbols.add(type: 'car',     parse_rule: '[type:make] [type:model] [type:cc]')
      end

      context 'two word sentence' do
        it "converts 'ford focus' into 'car' type" do
          result = subject.is_a("ford focus")
          expect(result).to match_array [
            "ford focus",
            "[type:car]",
            "[type:make] [type:model]",
            "[type:car] [type:model]",
            "[type:car] focus",
            "[type:make] focus",
            "ford [type:model]"
          ]
        end
      end

      context 'types with spaces' do
        it "converts '1.0' into 'cc' type" do
          skip
          result = subject.is_a("i want a ford")
          expect(result).to match_array [
            "i want a ford",
            "i want a [type:car]",
            "i want a [type:make]",
            "[type:subject] want a [type:car]",
            "[type:subject] want a ford",
            "[type:subject] want a [type:make]",
            #"[type:subject_wants] a [type:make]",
            #"[type:subject_wants] a ford",
          ]
        end
      end
    end
  end
end
