module NLU
  class Generalization
    class TypeKnowledge
      def initialize(symbols)
        @symbols = symbols || []
      end

      def is_a(word, loop_guard = 0)
        return word.to_s if loop_guard > 2
        return word.to_s if word.to_s.match(/\[type:unknown:.*\]/i)

        candidates = []

        #puts "INPUT: #{word.to_s}", loop_guard

        @symbols.each do |symbol_properties|
          symbol = symbol_properties[:symbol]
          type   = symbol_properties[:type].to_s
          rule   = symbol_properties[:parse_rule] || symbol

          #puts "-> #{type}|#{rule}", loop_guard

          next unless rule

          if rule.is_a?(String) && word.to_s == rule
            candidates << "[type:#{type}]"
          elsif rule.is_a?(Regexp) && word.to_s =~ rule
            candidates << word.to_s.gsub(
              rule,
              "[type:#{type}]"
            )
          end
        end

        #puts candidates.inspect, loop_guard

        if candidates.count == 0 && !word.to_s.match(/\[.*\]/)
          candidates << "[type:unknown:#{word}]"
        elsif candidates.any? { |c| c =~ /\[type:/ }
          candidates.map! do |current_candidate|
            is_a(
              ConceptWord.new(current_candidate, @symbols),
              loop_guard+1
            )
          end
        else
          candidates = [word.to_s]
        end

        # TODO - what if R$ matches [type:dollar] and [type:real]
        candidates.uniq!
        candidates.first.to_s
      end

      private

      def puts(str, level = 0)
        space = "\t" * level
        Kernel.puts "#{space}#{str}"
      end

      def type_from_placeholder(placeholder)
        placeholder.match(/\[type:(.*)\]/)[-1]
      end
    end
  end
end
