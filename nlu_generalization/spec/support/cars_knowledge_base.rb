module CarsKnowledgeBase
  def self.symbols
    symbols = NLU::Generalization::Symbols.new
    symbols.add(type: 'number', parse_rule: Regexp.new("[0-9]+"))

    symbols.add(type: 'make',  parse_rule: 'ford')
    symbols.add(type: 'make',  parse_rule: 'chevrolet')
    symbols.add(type: 'model', parse_rule: 'mustang')

    symbols.add(type: 'state',  parse_rule: 'new', belongs_to: 'car')

    # TODO ideally we should be able to define this separatelly, e.g
    #
    #   subject.symbol('car').is_defined_by([[:make], [:make]])
    #

    symbols.add(symbol: 'car', type: 'object', parse_rule: 'car')
    #symbols.add(type: 'car', parse_rule: '[type:make]')
    #symbols.add(type: 'car', parse_rule: '[type:model]')

    # TODO i don't think we need `belongs_to` here because if we define for
    # example
    #
    #   symbols.add(type: 'car', parse_rule: '[type:model]')
    #
    # then we can inder automatically `car.model = string-value` (where
    # model is an attribute)
    #
    # ---
    #
    # On the other hand, if we write `car 1.0`, we need to know that 1.0 is an
    # attribute that belongs to the car. `cc` is an attribute whereas `make` and
    # `model` are things that identify the car, closer to its nomenclature/id.
    symbols.add(type: 'cc', parse_rule: '[type:number].[type:number]', belongs_to: 'car')

    #symbols.add(symbol: 'hello', type: 'greeting')
    symbols
  end
end
