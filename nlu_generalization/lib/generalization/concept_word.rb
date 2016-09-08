module NLU
  class Generalization
    class ConceptWord
      def initialize(string, symbols)
        @string = string
        @symbols = symbols
      end

      def to_regex
        Regexp.new(escape_regex(@string), Regexp::IGNORECASE)
      end

      def to_s
        @string
      end

      def typed_function
        Generalization::TypeKnowledge.new(@symbols).is_a(self)
      end

      private

      def escape_regex(w)
        Regexp.escape(w)
      end
    end
  end
end
