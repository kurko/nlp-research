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
