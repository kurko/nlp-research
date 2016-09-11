# Sentence generalization 

## Introduction

Consider we have 99 things in the same category. I then implement the following
logic to respond to a sentence:

    when "$10 in restaurant" then createEntry()

Later on, if someone says, "$20 in clothing", wihtout ever having seen this
sentence before, you would infer that it follows the same rule as before and
would call `createEntry()` automatically.

That is possible for a human being because the listener knows that `clothing`
is a category. So how we connect the second sentence with the same outcome of
the first? When we first hear `$10 in restaurant`, we generalize it to
something close to `[dollars] [direction] [category]`. When we hear
`$20 in clothing`, we match against all the generalizations that we have created
in the past and find that the one above works.

We are able to generalize to things we have never heard before.

## The algorithm

We start by "teaching" a phrase to the program. Here are the steps.

1. The program has a list of symbols belonging to a type. Below, we have
restaurant and clothing symbols belonging to the _category_ type.


      CATEGORY = [restaurant, clothing, ..., etc]

  The types are organized by how fundamental they are. At the bottom of the
  hierarchy are the symbol that are physically fundamental, like shapes and
  drawings, and as hierarchy increases we find symbols that are abstract and
  that depend on the lower level symbols.

  Below we define the fundamental symbol _number_ and then we define the higher
  level, more abstract symbol _dollar_ as one that is composed by the
  _number_ type. In other words, more abstract types are mere compositions of
  more fundamental, lower level types.

      NUMBER = /[0-9]+/
      DOLLAR = "$[type:NUMBER]"

  Number is fundamental whereas Dollar is based on the knowledge of what a
  number is. `$[type:NUMBER]` means "a dollar sign followed by a number". We try
  to reduce the use of regex to fundamental blocks (e.g numbers).

2. We analyze word for word in a phrase and generalize to their Type. For
   instance

      "$10 in restaurant"

  becomes

      "[type:DOLLAR] [type:DIRECTION] [type:CATEGORY]"

3. We map type order with a function. All the following structures would call
   `createEntry`:

  * `[type:DOLLAR] [type:CATEGORY]`
  * `[type:CATEGORY] [type:DOLLAR]`
  * `[type:DOLLAR] [type:DIRECTION] [type:CATEGORY]`

  These differences can be tracked via dictionaries or neural nets, whatever
  proves to be more efficient in the short and long-term.

## Features

### Token generalization

This is the basic generalization, computing individual words.

    Symbols:
      { type: 'subject', symbol: 'i'      },
      { type: 'make',    symbol: 'ford'   },
      { type: 'make',    parse_rule: /gm/ }

    Lessons:
      'i want a ford' -> :a_function_name

    Generalization:
      '[type:subject] want a [type:make]' -> :a_function_name

    Result for input 'i want a gm':
      {
        fn: :a_function_name,
        attrs: {
          subject: 'i',
          make:    'gm'
        },
        score: '1.0'
      }

### Hierarchical generalization

This allows multiple iterations on the symbols and forming a hierarchical
generalization.

Below, we define the fundamental type, `number`,  and then define `cc` as
composed by the number type and the dot, like `[type:number].[type:number]`.
See the example below:

    Symbols:
      { type: 'subject', symbol: 'i'                           },
      { type: 'make',    symbol: 'ford'                        },
      { type: 'make',    symbol: 'gm'                          },
      { type: 'number',  parse_rule: /[0-9]+/                  },
      { type: 'cc',      symbol: '[type:number].[type:number]' }

    Lessons:
      'i want a ford 1.0' -> :a_function_name

    Generalization:
      '[type:subject] want a [type:make] [type:cc]' -> :a_function_name

    Result for input 'i want a gm 1.0':
      {
        fn: :a_function_name,
        attrs: {
          subject: 'i',
          make:    'gm',
          cc:      '1.0'
        },
        score: '1.0'
      }

### Transitive Type (WIP)

This allows to plug together different types to improve accuracy.

Below, we define the fundamental type, `subject` as `I` and `subject_wants` as
`[type:subject] want`. In the 1st iteration on `i want a ford`, subject is
found. In the 2nd iteration it finds `subject_wants`, elevating this
generalization's score.

See the example below:

    Symbols:
      { type: 'make',          symbol: 'ford'                },
      { type: 'subject',       symbol: 'i'                   },
      { type: 'subject_wants', symbol: '[type:subject] want [type:subject:object]' }

    Lessons:
      'i want a ford' -> :a_function_name

    Generalization:
      '[type:subject] want a [type:make]'         -> :a_function_name
      '[type:subject_wants] a [type:make]'        -> :a_function_name
      '[type:subject_wants] a [type:make]'        -> :a_function_name
      '[type:subject] want [type:subject:object]' -> :a_function_name

    Result for input 'i want a gm':
      {
        fn: :a_function_name,
        attrs: {
          subject: 'i',
          subject_wants: 'a gm',
          make:    'gm',
        },
        score: '1.0'
      }


## Roadmap

* upcased vs downcased symbols don't generalize well
