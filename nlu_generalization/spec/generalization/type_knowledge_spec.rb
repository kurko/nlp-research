require "spec_helper"

RSpec.describe NLU::Generalization::TypeKnowledge do
  subject { described_class.new(symbols) }

  before do
    $nlu_debug = false
  end

  describe "#is_a" do
    context 'no symbols found' do
      let(:symbols) { NLU::Generalization::Symbols.new }

      it "generalizes to types" do
        result = subject.is_a("car")
        expect(result).to eq "[type:unknown:car]"
      end
    end

    context 'single-level hierarchical symbols' do
      let(:symbols) do
        symbols = NLU::Generalization::Symbols.new
        symbols.add(symbol: 'ford', type: 'make')
        symbols.add(type: 'make', parse_rule: /gm/)
      end

      it "generalizes to types" do
        result = subject.is_a("ford")
        expect(result).to eq "[type:make]"

        result = subject.is_a("gm")
        expect(result).to eq "[type:make]"
      end
    end

    context 'multi-level hierarchical symbols' do
      let(:symbols) do
        symbols = NLU::Generalization::Symbols.new
        symbols.add(type: 'number', parse_rule: /[0-9]+/)
        symbols.add(type: 'cc',     parse_rule: '[type:number].[type:number]')
        symbols.add(type: 'make', symbol: 'ford')
        symbols.add(type: 'make', symbol: 'gm')
        symbols.add(type: 'car', parse_rule: '[type:make]')
      end

      context 'one word sentence' do
        it "converts 'ford' into 'car' type" do
          result = subject.is_a("ford")
          expect(result).to eq "[type:car]"
        end
      end

      context 'one word sentence with multi-level numbers' do
        it "converts '1.0' into 'cc' type" do
          result = subject.is_a("1.0")
          expect(result).to eq "[type:cc]"
        end
      end

      context 'a sentence' do
        it "generalizes to types" do
          expect(subject.is_a("I")).to    eq "[type:unknown:I]"
          expect(subject.is_a("want")).to eq "[type:unknown:want]"
          expect(subject.is_a("a")).to    eq "[type:unknown:a]"
          expect(subject.is_a("gm")).to   eq "[type:car]"
        end
      end
    end
  end
end
