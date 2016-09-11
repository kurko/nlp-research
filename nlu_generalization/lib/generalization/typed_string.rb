module NLU
  class Generalization
    class TypedString
      def initialize(symbols)
        @symbols = symbols || []
      end

      def is_a(sentence, loop_guard = 0)
        return sentence if loop_guard > 2
        return sentence if sentence.match(/\[type:unknown:.*\]/i)

        candidates = []

        #puts "INPUT: #{sentence.to_s}", loop_guard

        @symbols.each do |symbol_properties|
          symbol = symbol_properties[:symbol]
          type   = symbol_properties[:type].to_s
          rule   = symbol_properties[:parse_rule] || symbol
          token_length = symbol_properties[:token_length]

          #puts "-> #{type}|#{rule}", loop_guard
          next unless rule

          subsentence = sentence_with_n_words(sentence, token_length)

          result = subsentence.map do |string|
            #puts "subsentence #{subsentence}", loop_guard

            if rule.is_a?(String) && string == rule
              "[type:#{type}]"
            elsif rule.is_a?(Regexp) && string =~ rule
              string.gsub(rule, "[type:#{type}]")
            else
              string
            end
          end

          candidates << result.join(" ") # if result
        end

        #puts candidates.inspect, loop_guard

        candidates.map! do |current_candidate|
          if current_candidate =~ /\[type:/i
            is_a(current_candidate, loop_guard+1)
          else
            current_candidate
          end
        end

        if candidates.count == 0
          candidates << sentence
        end

        candidates.flatten.uniq
      end

      private

      def puts(str, level = 0)
        space = "\t" * level
        Kernel.puts "#{space}#{str}"
      end

      def type_from_placeholder(placeholder)
        placeholder.match(/\[type:(.*)\]/)[-1]
      end

      def sentence_with_n_words(sentence, n)
        sentence.split.each_slice(n).map { |slices| slices.join(" ") }
      end
    end
  end
end
