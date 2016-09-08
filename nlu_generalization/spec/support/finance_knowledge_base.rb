module FinanceKnowledgeBase
  def self.symbols
    symbols = NLU::Generalization::Symbols.new
    symbols.add(type: 'category',  parse_rule: 'restaurant')
    symbols.add(type: 'category',  parse_rule: 'clothing')
    symbols.add(type: 'direction', parse_rule: 'in')
    symbols.add(type: 'number',    parse_rule: Regexp.new("[0-9]+"))
    symbols.add(type: 'dollar',    parse_rule: "$[type:number]")

    symbols
  end
end
