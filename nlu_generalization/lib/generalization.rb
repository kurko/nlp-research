#require 'pry'
#require 'awesome_print'
require 'nlu'
require 'nlu_generalization/lib/generalization/symbols'
require 'nlu_generalization/lib/generalization/typed_string'
require 'nlu_generalization/lib/generalization/concept_word'
require 'nlu_generalization/lib/generalization/effect'
require 'nlu_generalization/lib/generalization/sentence'

# When we say,
#
# -> when i say $10 in restaurant, create an entry
#
# it should trigger a `teach` method. The `$10 in restaurant` statement is
# treated here, being called as follows:
#
# teach(cause: "$10 in restaurant", effect: :create_entry)
#
# TODO - `create an entry` needs to be mapped to `create_entry`.
#
module NLU
  class Generalization
    RESERVED_TYPES = {
      wildcard: "type:wildcard",
    }.freeze

    REGEX_POSSIBILITIES = [
      ".",
      "[a-z]+",
      "[0-9]+",
    ]

    attr_accessor :learned, :symbols

    # symbols base is a base with symbols linked to each other describing
    # rules to parse and identify them in sentences. Is is of type Symbols
    def initialize(symbols:)
      @symbols = symbols
      @learned = {}
    end

    def teach(cause:, effect:)

      # 1. TOKENIZE
      output = tokenize(cause)

      # 2. DEFINE REGEX CRITERIAS
      #
      # Includes generalization of words. For example, restaurant matches
      # /restaurant/, but also /#{any_category}/. This needs to be generated and
      # marked as a generalization. Then, if the user defines that a particular
      # case shouldn't be generalized ("I mean only restaurant, not any other
      # category"), then we need to remove this generalization.
      #
      # To avoid generalizing again, we need to not remove, but just mark as
      # ignored (e.g generalize: false)

      # 3. FIND GENERALIZATIONS
      #
      # In some cases such as the first time an occurrence appears,
      # a generalization will not exist. In other cases, it will already exist,
      # such as `[fn:amount]`.
      #
      # When it already exists (e.g amount, above), we reuse it.
      #
      # Another example is the list of categories we have predefined.

      generalizations = generalize(output)

      # 4. CREATE GENERALIZATIONS
      #
      # `[CATEGORY_TYPE]` as a means of generalization, e.g:
      #
      # `$10 in restaurant` can be generalized as `$10 in [SOME_CATEGORY]`. This
      # will depend on checking the Types module and finding `restaurant` defined
      # as a category.
      #
      # Set theory will have a significant role here.
      if @learned[effect].nil?
        @learned[effect] = {
          generalizations: []
        }
      end

      unless @learned[effect][:generalizations].include?(generalizations)
        @learned[effect][:generalizations] << generalizations
        @learned[effect][:generalizations] = @learned[effect][:generalizations].flatten.uniq
      end

      @learned
    end

    # Given we have something like this sentence and criteria,
    #
    #   sentence: "52 in clothing"
    #   criteria: `$[type:number] [type:position] [type:category]` => :create_entry
    #
    # We need to match those criterias and find candidate function names.
    #
    def effect_from_cause(cause)
      effect = Generalization::Effect.new(
        cause: cause,
        learned: @learned,
        symbols: @symbols
      ).calculate
      [effect].flatten.compact
    end

    def generalize(sentence)
      sentence = Sentence.new(sentence).tokenize.join(" ")

      Generalization::TypedString.new(@symbols).is_a(sentence)
    end

    private

    def split_in_chunks(str)
      str.split(" ")
    end

    def tokenize(str)
      str.downcase
    end

    # TODO - not being used
    def find_regex(words)
      Array(words).map do |w|
        regexes_for_word = []

        possible_regexes(w).each do |regex|
          #puts "Word: #{w} against #{regex} -> #{w =~ regex}"
          if w =~ regex
            regexes_for_word << regex
          end
        end

        regexes_for_word.uniq
      end
    end

    def escape_regex(w)
      Regexp.escape(w)
    end

    # TODO - not being used
    def possible_regexes(w)
      possible = []
      w_as_regex = escape_regex(w)

      # Here we specify many different functions that generate regex criterias,
      #
      # For example, /\$10/ and /\$[0-9]+/ for $10
      possible << w_as_regex
      possible << w_as_regex.gsub(/[0-9]/, "[0-9]+")

      possible.uniq.map { |p| Regexp.new(p, Regexp::IGNORECASE) }
    end
  end
end
