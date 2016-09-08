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

        cause_sentence = Sentence.new(@cause).tokenize

        generalized_cause = NLU::Generalization.new(symbols: @symbols).generalize(@cause)

        @learned.each do |function_name, criteria|
          criteria[:generalizations].each do |generalization|

            local_candidate = {
              fn: function_name,
              attrs: { },
              score: 0.0
            }
            # We will match *each* known generalization against the cause
            # generalization.
            match_starts_at_cause_position = nil
            generalization.each_with_index do |rule, index|

              generalized_cause.each_with_index do |cause_rule, cause_index|
                if rule == cause_rule
                  match_starts_at_cause_position ||= cause_index

                  local_candidate[:score] += 1
                  param = type_as_param(cause_rule)
                  local_candidate[:attrs][param] = cause_sentence[cause_index]
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
