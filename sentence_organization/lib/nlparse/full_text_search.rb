require 'awesome_print'
require 'fuzzystringmatch'
#require 'nlparse/sentence_concept'

class NLParse
  class FullTextSearch
    #CATEGORIES = {
    #  "lazer" => [{
    #    "jantar fora" => {
    #      what: "comida"
    #    }
    #  }],
    #  "trabalho" => [{
    #    "jantar fora" => {
    #      what: "comida"
    #    }
    #  }]
    #}
    CATEGORIES = [
      { name: "lazer",       parent: "",         keywords: "" },
      { name: "jantar fora", parent: "lazer",    keywords: "comida" },

      { name: "trabalho",    parent: "",         keywords: "" },
      { name: "jantar fora", parent: "trabalho", keywords: "comida" },
    ]

    ACCOUNTS = [
      "visa 2494",
      "master 2494"
    ]

    def initialize(sentence)
      @sentence = sentence
      @concept = nil
    end

    def category
      @category = ''

      candidates = []
      CATEGORIES.each_with_index do |cat, i|
        target_string = cat[:name]

        distance = jarow.getDistance(target_string, @sentence)
        #ap "#{cat[:name]}: #{distance}"
        if distance > 0.8
          candidates << cat
        end
      end

      #ap candidates
      candidates.first[:name]
    end

    def account
      @account = ''

      candidates = []
      ACCOUNTS.each_with_index do |name, i|
        target_string = name

        distance = jarow.getDistance(target_string, @sentence)
        ap "#{name}: #{distance}"
        if distance > 0.8
          candidates << name
        end
      end

      #ap candidates
      candidates.first
    end

    private

    def tokenized
      @sentence
        .gsub(/[\.,]/, ' ')
        .gsub(/\s{2}/, ' ')
        .split(" ")
    end

    def jarow
      @jarow ||= FuzzyStringMatch::JaroWinkler.create(:native)
    end
  end
end
