# Sentence generalization

Consider we have 99 things in the same category. I then implement the following
logic to respond to a sentence:

    when "$10 in restaurant" then createEntry()

Later on, if someone said to you, "$20 in clothing", you would infer that it
follows the same rule as before and would call `createEntry()` automatically. We
are able to generalize to things we have never heard before.

We start by "teaching" a phrase to the program. Here are the steps.

1. The program has a list of categories and a list of words that mean direction.

      CATEGORY = [restaurant, clothing, ..., etc]
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
