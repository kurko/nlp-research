module NLU
  class Generalization
    class Effect
      def initialize(cause:, learned:, symbols:)
        @cause = cause
        @learned = learned
        @symbols = symbols
      end

      def calculate
        initial_candidates = []
        final_candidates = []

        generalized_cause = NLU::Generalization.new(symbols: @symbols).generalize(@cause)

        #ap "sentence: #{cause_sentence}"
        #ap "learned:"
        #ap @learned

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

            # We then generalize the cause sentence and go through it.
            # We will match *each* learned generalization against the cause
            # generalization.
            generalized_cause.each_with_index do |cause_rule, cause_index|

              #ap "generalized_cause #{cause_rule}"
              #ap "generalization #{generalization}"

              # If we find a learned generalization that matches the generalized
              # sentence, we will save it.
              if generalization == cause_rule

                #ap ""
                #ap cause_rule.split(" ")
                #ap cause_sentence
                #ap "generalization #{generalization}"
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
                    type = type_as_param(typed_string)
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
                  end
                end

              end
            end

            if local_candidate[:score] > 0
              initial_candidates << local_candidate
            end
          end
        end

        initial_candidates = normalize_scores(initial_candidates)

        initial_candidates.each do |candidate|
          if candidate[:score] > 0.75
            final_candidates << candidate
          end
        end
        final_candidates
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

      # Replaces [type:category] with `:category`
      def type_as_param(type)
        type
          .gsub(/\[.*:/, '')
          .gsub(/\]/, '')
          .to_sym
      end
    end
  end
end
