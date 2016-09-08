module NLU
  class Generalization
    class Sentence
      def initialize(string)
        @string = string
      end

      def tokenize
        @string
          .downcase
          .gsub(/\. /, ' ')
          .split(" ")
      end
    end
  end
end
