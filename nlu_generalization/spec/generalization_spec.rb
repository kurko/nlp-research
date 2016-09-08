require "spec_helper"

RSpec.describe NLU::Generalization do

  subject { described_class.new(symbols: symbols) }

  before do
    $nlu_debug = false
  end

  describe '#teach' do
    context 'simple lesson' do
      let(:symbols) do
        symbols = NLU::Generalization::Symbols.new
        symbols.add(symbol: 'ford', type: 'make')
      end

      it 'learns it' do
        learned = subject.teach(cause:"i want a ford", effect: :search_car)

        expect(learned).to eq({
          search_car: {
            generalizations: [
              [
                "[type:unknown:i]",
                "[type:unknown:want]",
                "[type:unknown:a]",
                "[type:make]"
              ]
            ]
          }
        })
      end
    end

    context 'duplicated lesson' do
      let(:symbols) do
        symbols = NLU::Generalization::Symbols.new
        symbols.add(symbol: 'ford', type: 'make')
        symbols.add(symbol: 'gm', type: 'make')
      end

      it 'learns it' do
        learned = subject.teach(cause:"i want a ford", effect: :search_car)
        learned = subject.teach(cause:"i want a gm",   effect: :search_car)
        learned = subject.teach(cause:"i want a gm",   effect: :search_a_gm)

        expect(learned).to eq({
          search_car: {
            generalizations: [
              [
                "[type:unknown:i]",
                "[type:unknown:want]",
                "[type:unknown:a]",
                "[type:make]"
              ]
            ]
          },
          search_a_gm: {
            generalizations: [
              [
                "[type:unknown:i]",
                "[type:unknown:want]",
                "[type:unknown:a]",
                "[type:make]"
              ]
            ]
          }
        })
      end
    end
  end

  context "finance app" do
    let(:symbols) { FinanceKnowledgeBase.symbols }

    it "learns a phrase structure" do
      skip
      subject.teach(cause:"$10 in restaurant", effect: :create_entry)
      subject.teach(cause:"10 in restaurant",  effect: :create_entry)
      # $[type:number] [type:direction] [type:category]
      # attrs: {
      #   number: "10",
      #   position: "in",
      #   category: "restaurant"
      # }

      effect = subject.effect_from_cause("hello. I spent 53 in clothing")
      expect(effect).to eq [{
        fn: :create_entry,
        score: 1.0,
        attrs: {
          number: "53",
          position: "in",
          category: "clothing"
        }
      }]
    end
  end

  context "cars app" do
    let(:symbols) { CarsKnowledgeBase.symbols }

    it "learns a phrase structure" do
      #subject.teach(cause:"hello", effect: :greeting)
      #subject.teach(cause:"hi", effect: :greeting)
      subject.teach(cause:"I want a car 1.0", effect: :search_product)
      #subject.teach(cause:"I want a 1.0 car", effect: :search_product)
      #subject.teach(cause:"I want a new car", effect: :search_product)

      ap "learned #{subject.learned.inspect}"
      ap "------------"

      #effect = subject.effect_from_cause("hello. I want a 1.0 car")
      #expect(effect).to eq [{
      #  fn: :search_product,
      #  attrs: {
      #    cc: "1.0",
      #    object: "car"
      #  },
      #  score: 1.0
      #}]

      #ap subject.teach("10 in restaurant", fn: :create_entry)
      # $[type:number] [type:position] [type:category]
      #subject.teach("$10 in restaurant", fn: :create_entry)
    end
  end

  context "fundamental blocks" do
    describe "currency" do
      it "learns about $10" do
        skip
      end
    end
  end
end
