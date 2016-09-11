class NLParse
  class SentenceConcept
    attr_reader :direct_object, :indirect_object

    def initialize(
      sentence:,
      #subject:,
      verb:,
      direct_object:,
      indirect_object:
    )
      @sentence = sentence
      @verb = verb
      @direct_object = direct_object
      @indirect_object = indirect_object
    end
  end
end
