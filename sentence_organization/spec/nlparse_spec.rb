require 'rspec'
require 'nlparse'

RSpec.describe NLParse do
  subject { described_class.new(sentence) }

  before do
    subject.set_words(
      subjects: ['Mary'],
      prepositions: ['de', 'para'],
      verbs: {
        transitive_direct: ['comprou', 'gastou', 'peguei'],
        transitive_indirect: []
      },
      pronouns: ['um'],
      quantities: ['um', 'dois', 'três'],
      adjectives: ['branco']
    )
  end

  describe 'object' do
    fixtures = [{
        sentence: 'Mary comprou o caderno',
        direct_object: 'o caderno'
      }, {
        sentence: 'Mary comprou dois cadernos brancos para John',
        direct_object: 'dois cadernos brancos',
        indirect_object: 'para John',
      }, {
        sentence: 'Mary gastou 50 reais para andar de ônibus',
        verb: 'cadernos',
        direct_object: '50 reais',
        indirect_object: 'andar de ônibus',
      }, {
        sentence: 'peguei 50 com john para arrumar o ventilador',
        direct_object: '50 com john',
        indirect_object: 'para arrumar o ventilador'
      }]


    fixtures.each do |sample|
      context "sentence: #{sample}" do
        let(:sentence) { sample[:sentence] }

        it 'return' do
          sentence = sample[:sentence]
          direct_object = sample[:direct_object]
          indirect_object = sample[:indirect_object]

          unless sentence.nil?
            result = subject.sentence
            expect(result.direct_object).to eq direct_object
            if indirect_object
              expect(result.indirect_object).to eq indirect_object
            end
          end
        end
      end
    end
  end
end
