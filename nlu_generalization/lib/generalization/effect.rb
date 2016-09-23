module NLU
  class Generalization
    class Effect
      def initialize(cause:, learned:, symbols:)
        @cause = cause
        @learned = learned
        @symbols = symbols
      end

      # This will:
      #
      # 1. take what was learned (generalizations)
      # 2. generalize the new sentence
      # 3. check whether both generalizations match
      #
      def calculate
        candidates = []

        generalized_cause = NLU::Generalization.new(symbols: @symbols).generalize(@cause)

        #ap "sentence: #{cause_sentence}"
        #ap "learned: #{@learned.inspect}"

        # We go through everything that was learned before
        @learned.each do |function_name, criteria|
          criteria[:generalizations].each do |generalization|

            # We generate a pre-candidate for this generalization. It starts
            # with score zero because we don't know yet whether this criteria
            # fits the sentence or not.
            local_candidate = {
              fn: function_name,
              attrs: { },
              score: 0.0
            }

            #ap "generalized_cause #{generalized_cause}"

            # We then generalize the cause sentence and go through it.
            # We will match *each* learned generalization against the cause
            # generalization.
            generalized_cause.each_with_index do |cause_rule, cause_index|


              # Wildcard
              #
              # Matches these:
              #
              #   > i want a [type:wildcard:some_name_for_this_wildcard]
              #   > i want a ford
              #
              wildcard = "[#{NLU::Generalization::RESERVED_TYPES[:wildcard]}]"
              #ap "wildcard: #{wildcard}"
              wildcard_regex = Regexp.escape(wildcard)
              if generalization =~ /wildcard/i
                wildcard_generalization = generalization
                  .gsub(/\[(type:wildcard)(.+)\]/i, '[\1]')
              end
              #ap "wildcard_generalization(#{wildcard_generalization}) =~ cause_rule(#{wildcard_regex})"
              if wildcard_generalization.to_s =~ Regexp.new(wildcard_regex, Regexp::IGNORECASE)
               #ap "true -> #{wildcard_generalization} =~ /#{Regexp.new(wildcard_regex, Regexp::IGNORECASE)}/i"

                rule = wildcard_generalization.gsub("#{wildcard}", "(.+)")
                #ap "rule #{rule}"
                #binding.pry
                if value = cause_sentence.join(" ").match(Regexp.new(rule, Regexp::IGNORECASE))
                  value = value[-1]
                  prop = attr_name_from_type_param(generalization)

                  local_candidate = local_candidate.merge({
                    attrs: {
                      prop => value
                    },
                    score: 0.75
                  })
                end

              # If we find a learned generalization that matches the generalized
              # sentence, we will save it.
              elsif generalization == cause_rule
                cause_rule.split(" ").each_with_index do |typed_string, index|

                  # If the learned generalization has a type anywhere, we will
                  # check what is the corresponding word in the cause sentence.
                  #
                  # For example, consider the following sentence:
                  #
                  #   [type:subject] want a [type:make]
                  #
                  # and the sentence
                  #
                  #   I want a ford
                  #
                  # Finding `[type:make]` at position 3 of the array, we will
                  # get `ford` at the position 3 of the cause sentence. With
                  # that we can come up with `{make: 'ford'}`.
                  #
                  if typed_string =~ /\[type/i
                    local_candidate[:score] += 1
                    type = attr_name_from_type_param(typed_string)
                    prop = type_properties(type)
                    type_token_length = prop[:token_length]

                    # In `i want a car`, this will get the `i`. If the type
                    # says instead that it's formed by two symbols (e.g
                    # `i want`), then it will take `i want`.
                    #
                    # The -1 in the brackets is because otherwise it would be
                    # translated to the following if the type had 1 symbol
                    #
                    #   cause_sentence[1..1+1]
                    #
                    # That would take 2 words (`[1..2]`). We want one word, so
                    #
                    #   cause_sentence[1..1+1-1]
                    #
                    word_for_type = cause_sentence[index..index+(type_token_length-1)]
                    #ap "> type: #{type} - #{index} #{cause_sentence[index..index+type_token_length]}"

                    local_candidate[:attrs][type] = word_for_type.join(" ")

                  # When it's just the same sentence as one seen before, no
                  # generalizations
                  else
                    local_candidate[:score] = 1
                  end
                end

              end
            end

            if local_candidate[:score] > 0
              candidates << local_candidate
            end
          end
        end

        # TODO - normalization is taking out some elements that are good.
        #candidates = normalize_scores(candidates)
        candidates = pick_candidates(candidates)
        candidates = merge_attributes(candidates)

        candidates
      end

      private

      def cause_sentence
        @cause_sentence ||= Sentence.new(@cause).tokenize
      end

      def type_properties(type)
        @symbols.find { |symbol| symbol[:type].to_s == type.to_s }
      end

      def normalize_scores(candidates)
        candidates = candidates.dup
        max_score = candidates.map { |candidate| candidate[:score] }.max
        candidates.map do |candidate|
          candidate[:score] = candidate[:score] / max_score
          candidate
        end
      end

      def pick_candidates(candidates)
        candidates.dup.keep_if { |candidate| candidate[:score] >= 0.75 }
      end

      # merge_attributes
      #
      # This takes the following:
      #
      #   [{
      #     fn: :search_car,
      #     attrs: {
      #       make: "ford",
      #     },
      #     score: 1.0
      #   }, {
      #     fn: :search_car,
      #     attrs: {
      #       wildcard: "ford focus"
      #     },
      #     score: 0.75
      #   }]
      #
      # into the following:
      #
      #   [{
      #     fn: :search_car,
      #     attrs: {
      #       make: "ford",
      #       wildcard: "ford focus"
      #     },
      #     score: 1.0
      #   }]
      #
      def merge_attributes(candidates)
        new_candidates = []
        candidates.dup.each do |candidate|
          not_processed_yet = new_candidates.none? { |c| c[:fn] == candidate[:fn] }

          if not_processed_yet
            corresponding_candidate = candidates.select { |c| c[:fn] == candidate[:fn] }
            merged_attributes = corresponding_candidate
              .map    { |c| c[:attrs] }
              .reduce({}, :merge)

            candidate[:attrs] = merged_attributes
            candidate[:score] = corresponding_candidate.map { |c| c[:score] }.max
            new_candidates << candidate
          end
        end

        new_candidates
      end

      # Replaces [type:category] with `:category`
      def attr_name_from_type_param(type)
        #ap "type #{type}"
        type
          .split(":")
          .last
          .gsub(/\[.*:/, '')
          .gsub(/\]/, '')
          .to_sym
      end
    end
  end
end
