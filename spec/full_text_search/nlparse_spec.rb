require 'rspec'
require 'nlparse'
require 'nlparse/full_text_search'

RSpec.describe NLParse::FullTextSearch do
  fixtures = [{
    sentence: 'jantar fora. 36',
    category: 'jantar fora',
  }, {
    sentence: 'jantar fora. 36 no visa',
    category: 'jantar fora',
    account: 'visa 2494'
  }]

  subject { described_class.new(sentence) }

  fixtures.each do |sample|
    context "testing sample '#{sample[:sentence]}'" do
      let(:sentence) { sample[:sentence] }

      it "returns category '#{sample[:category]}'" do
        expect(subject.category).to eq sample[:category]
      end

      if sample[:account]
        it "returns account '#{sample[:account]}'" do
          expect(subject.account).to eq sample[:account]
        end
      end
    end
  end
end
