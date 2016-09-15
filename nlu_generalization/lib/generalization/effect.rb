module NLU
  class Generalization
    class Effect

      CANDIDATE_BLUEPRINT = {
        fn: nil,
        attrs: { },
        score: 0.0
      }.freeze

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

            candidate = {}

            # We then generalize the cause sentence and go through it.
            # We will match *each* learned generalization against the cause
            # generalization.
            generalized_cause.each_with_index do |cause_rule, cause_index|

              #ap "generalized_cause #{cause_rule}"
              ap "if generalization(#{generalization}) == cause_rule(#{cause_rule}) -> #{generalization == cause_rule}"

              # If we find a learned generalization that matches the generalized
              # sentence, we will save it.
              if generalization == cause_rule
                candidate = candidate_by_matched_generalization(cause_rule)
              else
                # Generates uncertainty
                candidate = candidate_by_proximity_symbol(cause_rule)
              end
            end

            if candidate[:score].to_i > 0
              candidate[:fn] = function_name
              initial_candidates << candidate
            end
          end
        end

        ap initial_candidates
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

      # candidate_by_matched_generalization
      #
      # Given *both* generalized lesson and cause is the same, this returns the
      # a candidate.
      #
      # e.g [type:make] [type:model] matches with what was typed now.
      def candidate_by_matched_generalization(cause_rule)
        candidate = CANDIDATE_BLUEPRINT.dup

        ap cause_rule
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
          if typed_string =~ /\[type/i
            candidate[:score] += 1
            type = type_as_param(typed_string)
            prop = type_properties(type)
            type_token_length = prop[:token_length]

            #ap "-> |#{type}, #{index}| #{cause_sentence[index..index+type_token_length]}"

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

            candidate[:attrs][type] = word_for_type.join(" ")
          end
        end

        candidate
      end

      # candidate_by_proximity_symbol
      #
      # In a generalization with multiple tokens (at least one space \s exists),
      # given one symbol matches then the adjacent ones could be potential
      # symbols that are just unknown. In that case we return this entry
      # as candidate but add an :uncertainty flag and a lower score.
      #
      # e.g [type:make] [type:model] matches with what was typed now.
      def candidate_by_proximity_symbol(cause_rule)
        {}
      end
    end
  end
end
