require 'awesome_print'
require 'nlparse/sentence_concept'

class NLParse
  def initialize(sentence)
    @sentence = sentence
    @concept = nil
  end

  def set_words(
    subjects:,
    prepositions:,
    verbs:,
    pronouns:,
    quantities:,
    adjectives:
  )
    @subjects = subjects
    @prepositions = prepositions
    @transitive_direct_verbs   = verbs[:transitive_direct]
    @transitive_indirect_verbs = verbs[:transitive_indirect]
    @quantities = quantities
    @pronouns = pronouns
    @adjectives = adjectives
  end

  def sentence
    parse
    @concept = NLParse::SentenceConcept.new(
      sentence: @sentence,
      verb: @verb,
      direct_object: @direct_object.join(' '),
      indirect_object: @indirect_object.join(' ')
    )
  end

  def parse
    verb_position = nil
    @direct_object = []
    @direct_object_context = false
    @indirect_object = []
    @indirect_object_context = false

    tokenized.each_with_index do |word, index|
      if verb?(word)
        verb_position = index
        @verb = index
        next
      end

      if !@verb.nil?
        if preposition?(word)
          break
        end

        @direct_object << word
        #if word.to_i > 0
        #  object << word
        #elsif pronoun?(word) # || quantity?(word)
        #  object << word if object.nil?
        #end
      end
      #ap "verb_position is #{verb_position}"
    end
  end

  private

  def tokenized
    @sentence.split(" ")
  end

  def verb?(word)
    transitive_direct_verb?(word) || transitive_indirect_verb?(word)
  end

  def transitive_direct_verb?(word)
    @transitive_direct_verbs.include?(word)
  end

  def transitive_indirect_verb?(word)
    @transitive_indirect_verbs.include?(word)
  end

  def quantity?(word)
    @quantities.include?(word)
  end

  def pronoun?(word)
    @pronouns.include?(word)
  end

  def preposition?(word)
    @prepositions.include?(word)
  end
end
