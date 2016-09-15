require "spec_helper"

RSpec.describe NLU::Generalization::Effect, "uncertainty feature" do
  subject { described_class.new(cause: cause, learned: learned, symbols: symbols) }

  before do
    $nlu_debug = false
  end

  describe "#calculate" do
    context 'given "[type1] [type2]" sentence' do
      let(:symbols) do
        symbols = NLU::Generalization::Symbols.new
        symbols.add(type: 'make',  symbol: 'ford')
        symbols.add(type: 'model', symbol: 'fusion')
        symbols.add(type: 'model', symbol: 'fiesta')
      end

      let(:learned) do
        generalization = NLU::Generalization.new(symbols: symbols)
        generalization.teach(cause: 'ford fusion', effect: :car_fn)
      end

      context 'when neither type1 nor type2 are known' do
        let(:cause) { 'abc def' }

        it 'returns nothing' do
          expect(subject.calculate).to eq([])
        end
      end

      context 'when type1 is known but type2 is not' do
        context 'sentence has no explanation' do
          let(:cause) { 'ford abc' }

          it 'marks "abc" as uncertain, but probable :model' do
            ap learned
            expect(subject.calculate).to eq([{
              fn: :car_fn,
              attrs: {
                make:  "ford",
                model: "abc"
              },
              uncertainty: {
                model: "abc"
              },
              score: 1.0
            }])
          end
        end

        context 'sentence has no explanation' do

          let(:cause) { 'ford abc. abc is the model' }
        end
      end

      context 'when type2 is known but type1 is not' do
        let(:cause) { 'abc fusion' }

        it 'marks "abc" as uncertain, but probable :make' do

        end
      end

      context 'when both type1 and type2 are known' do
        let(:cause) { 'ford fiesta' }

        it 'returns type1 and type2 attributes with certainty' do
          expect(subject.calculate).to eq([{
            fn: :car_fn,
            attrs: {
              make:  "ford",
              model: "fusion"
            },
            score: 1.0
          }])
        end
      end
    end
  end
end
