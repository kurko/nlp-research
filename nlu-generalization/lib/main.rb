require 'pry'
require 'awesome_print'
require 'text'

# When we say,
#
# -> when i say $10 in restaurant, create an entry
#
# it should trigger a `teach` method. The `$10 in restaurant` statement is
# treated here, being called as follows:
#
# teach("$10 in restaurant", fn: :create_entry)
#
# TODO - `create an entry` needs to be mapped to `create_entry`.
#
class NLStudent
  REGEX_POSSIBILITIES = [
    ".",
    "[a-z]+",
    "[0-9]+",
  ]

  def initialize
    @criterias = {}
  end

  def teach(input, fn:)

    # 1. TOKENIZE
    output = tokenize(input)

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

    generalizations = find_generalizations(output)

    # 4. CREATE GENERALIZATIONS
    #
    # `[CATEGORY_TYPE]` as a means of generalization, e.g:
    #
    # `$10 in restaurant` can be generalized as `$10 in [SOME_CATEGORY]`. This
    # will depend on checking the Types module and finding `restaurant` defined
    # as a category.
    #
    # Set theory will have a significant role here.
    @criterias[fn] = {} if @criterias[fn].nil?

    #generalizations.each do |word|
      puts "criteria for `#{input}` -> #{generalizations}"
      #regexes = find_regex(word)
      @criterias[fn] = {
        generalizations: generalizations
        #regexes: regexes.flatten
      }
    #end

    #puts regexes.join(" - ")
    @criterias
  end

  private

  def split_in_chunks(str)
    str.split(" ")
  end

  def tokenize(str)
    str.downcase
  end

  def find_generalizations(sentence)
    words = sentence.split(" ")
    words.map do |word|
      ConceptWord.new(word).typed_function
    end
  end

  def find_regex(words)
    Array(words).map do |w|
      regexes_for_word = []

      possible_regexes(w).each do |regex|
        puts "Word: #{w} against #{regex} -> #{w =~ regex}"
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

module Functions
  def list
    [{
      name: :create_entry,
      arguments: {
        amount: Integer,
        category: Category
      },
    }, {
      name: :list_entries
    }]
  end
end

module TypeKnowledge
  LIST = {
    # SET OF WORDS
    category: [{
      name: "restaurant",
    }, {
      name: "clothing"
    }],

    # SET OF WORDS
    position: [{
      name: "in",
      fn: :inside
    }],

    # CONTEXTUAL BLOCK (depends on a fundamental block, e.g $10)
    currency_number: [{
      name: "dollar",
      fn: :number,
      rule: "$[type:number]"
    }],

    # FUNDAMENTAL BLOCK
    number: [{
      name: "number",
      fn: :number,
      regex_rule: Regexp.new("[0-9]+")
    }]
  }

  def self.is_a(word, loop_guard = 0)
    return word.to_s if loop_guard > 10
    candidates = []
    TypeKnowledge::LIST.each_pair do |type_name, type_set|
      type_set.each do |set_item|
        puts "#{type_name} #{set_item[:name]} (#{set_item[:regex_rule]}) =~ #{word.to_regex}"

        if !set_item[:rule].nil? && word.to_s == set_item[:rule]
          candidates << "[type:#{type_name.to_s}]"
        end

        if !set_item[:regex_rule].nil? && word.to_s =~ set_item[:regex_rule]
          candidates << word.to_s.gsub(
            set_item[:regex_rule],
            "[type:#{type_name.to_s}]"
          )
        end

        if word.to_s == "in"
          candidates << "[type:position]"
        end

        if set_item[:name] =~ word.to_regex
          candidates << "[type:#{type_name}]"
        end
      end
    end

    if candidates.any? { |c| c =~ /\A[^\[]/ }
      candidates.map! do |candidate|
        TypeKnowledge.is_a(ConceptWord.new(candidate), loop_guard+1)
      end
    end

    # TODO - what if R$ matches [type:dollar] and [type:real]
    ap "candidates for #{word.to_s}: #{candidates}"
    candidates.uniq!
    #best_candidate = ""
    #best_distance = 99999

    #candidates.each do |candidate|
    #  distance = Text::Levenshtein.distance(candidate, word.to_s)
    #  if distance < final_distance
    #    best_distance = final
    #    best_candidate = candidate
    #  end
    #end
    candidates.first.to_s
  end
end

class ConceptWord
  def initialize(string)
    @string = string
  end

  def to_regex
    Regexp.new(escape_regex(@string), Regexp::IGNORECASE)
  end

  def to_s
    @string
  end

  def typed_function
    TypeKnowledge.is_a(self)
  end

  private

  def escape_regex(w)
    Regexp.escape(w)
  end
end
