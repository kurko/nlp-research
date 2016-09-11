# NLU Timeline

Usage

```ruby
class DummyPerson
  include NLU::Timeline
end

object1 = DummyPerson.new
object2 = DummyPerson.new

# Set attributes with the `set_attribute` function
object1.set_attribute(:name, 'object 1 name 1')
object2.set_attribute(:name, 'object 2 name 1')
object1.set_attribute(:name, 'object 1 name 2')
object2.set_attribute(:name, 'object 2 name 2')

# Get the current attribute
object1.attribute(:name) # => 'object 1 name 2'

# Get the global timeline
NLU::Timeline::GlobalStore.timeline
```
