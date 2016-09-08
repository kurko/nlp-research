# NLU research

This codebase has a few projects researching different aspects of NLP and how
to plug it into functions via AI/basic algorithms. Each directory is a different
project.

## Generalization algorithm

There's one drawback with current neural networks approach: it needs hundreds
of thousands of samples and training epochs to work properly. It's
understandable that nature took that direction as it went through a series of
trial and error, evolutionary branches. However, with the disposal of customizable algorithms at
our hands we can envision taking that lengthy process and transform it in
something that is less inefficient.

Consider an algorithm that is shown a handwritten letter A. In the traditional
way, a neural net will skim the image a few thousand times. A novel approach
([Lake,
2015](https://www.technologyreview.com/s/544376/this-ai-algorithm-learns-simple-tasks-as-fast-as-we-do/))
, on
the other hand, involves trying to draw the handwritten letter a handful of
times by letting the algorithm write an algorithm for drawing the letter. The
first attempts will look bad, like a child trying to draw something. The error
is calculated and acceptable up to a point.

This project attempts to apply this technique to text. Taking the sentence,
`$10 in restaurant`, it will convert it to a generalized tokenized
sequence such as `[type:dollar] [type:direction] [type:category]` and link
it to a symbol (eg. `create_entry`). Later, when shown `$50 in clothing`, it
will generalize again and find the previous generalization memorized, and
automatically retrieve the symbol `create_entry`.

### nlu-timeline framework

Everything happens in regards to time. Every-little-things. This framework
creates a framework to replace basic variables so that we can go back in time
and reason about things in relation to what once wasn't.

### fundamental-conceptualization

Assumes fundamental, physical position and movements as meaning for higher-level
concepts.

### nlu-organization

**DEPRECATED:** it won't be developed for now because a child doesn't try to
figure out what is the verb and etc.

Figures out what's the structure of the sentence.
