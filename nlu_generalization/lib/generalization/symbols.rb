module NLU
  class Generalization
    class Symbols
      include Enumerable

      def initialize
        @base = []
      end

      # Parameters
      #
      # - symbol: the symbol itself, e.g car, product, ipad, tablet, the word.
      #
      #           If a :parse_rule is provided then that will be used to figure
      #           out the text. Otherwise, :symbol will be used.
      #
      #           If :symbol is provided, it will be used as parameter.
      #
      # - type: can be a symbol or a new word. For example, a `restaurant` symbol
      #   is of type `category`, but it's also of the type `place`.
      #
      # Example:
      #
      #   symbol: 'restaurant', type: 'category'
      #   symbol: 'clothing',   type: 'category'
      #   symbol: 'in',         type: 'direction'
      #   symbol: 'number',     type: 'number', rule: Regexp.new("[0-9]+")
      #   symbol: 'dollar',     type: 'currency_number', rule: "$[type:number]"
      #
      #
      def add(
        symbol: nil,
        type:,
        belongs_to: nil,
        parse_rule: nil
      )
        @base << {
          symbol:     symbol,
          type:       type,
          belongs_to: belongs_to,
          parse_rule: parse_rule
        }
        self
      end

       def each(&block)
         @base.each(&block)
       end
    end
  end
end
