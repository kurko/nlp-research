require "spec_helper"

RSpec.describe NLU::Generalization::TypedString do
  subject { described_class.new(symbols) }

  before do
    $nlu_debug = false
  end

  describe "#is_a" do
    context 'no symbols found' do
      let(:symbols) { NLU::Generalization::Symbols.new }

      it "generalizes to types" do
        result = subject.is_a("car")
        expect(result).to match_array [
          "car"
        ]
      end
    end

    context 'single-level hierarchical symbols' do
      let(:symbols) do
        symbols = NLU::Generalization::Symbols.new
        symbols.add(symbol: 'ford', type: 'make')
        symbols.add(type: 'make', parse_rule: /gm/)
      end

      context "single word" do
        it "generalizes to types" do
          result = subject.is_a("ford")
          expect(result).to match_array [
            "[type:make]",
            "ford",
          ]

          result = subject.is_a("gm")
          expect(result).to match_array [
            "[type:make]",
            "gm",
          ]
        end
      end

      context "multiple words" do
        it "generalizes to types" do
          result = subject.is_a("super ford")
          expect(result).to match_array [
            "super [type:make]",
            "super ford"
          ]

          result = subject.is_a("gm")
          expect(result).to match_array [
            "[type:make]",
            "gm"
          ]
        end
      end
    end

    context 'multi-level hierarchical symbols' do
      let(:symbols) do
        symbols = NLU::Generalization::Symbols.new
        symbols.add(type: 'number',  parse_rule: /[0-9]+/)
        symbols.add(type: 'cc',      parse_rule: '[type:number].[type:number]')
        symbols.add(type: 'subject', parse_rule: 'i')
        #symbols.add(type: 'subject_wants', parse_rule: '[type:subject] want')
        symbols.add(type: 'make',    symbol: 'ford')
        symbols.add(type: 'make',    symbol: 'gm')
        symbols.add(type: 'car',     parse_rule: '[type:make]')
      end

      context 'one word sentence' do
        it "converts 'ford' into 'car' type" do
          result = subject.is_a("ford")
          expect(result).to match_array [
            "ford",
            "[type:car]",
            "[type:make]"
          ]
        end
      end

      context 'types with spaces' do
        it "converts '1.0' into 'cc' type" do
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

      context 'one word sentence with multi-level numbers' do
        it "converts '1.0' into 'cc' type" do
          result = subject.is_a("1.0")
          expect(result).to match_array [
            "1.0",
            "[type:cc]",
            "[type:number].[type:number]"
          ]
        end
      end

      context 'a sentence' do
        it "generalizes to types" do
          expect(subject.is_a("I")).to    match_array ["I"]
          expect(subject.is_a("want")).to match_array ["want"]
          expect(subject.is_a("a")).to    match_array ["a"]
          expect(subject.is_a("gm")).to   match_array [
            "gm",
            "[type:car]",
            "[type:make]"
          ]
        end
      end
    end
  end
end
