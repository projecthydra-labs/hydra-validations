hydra-validations
=======================

Custom validators for Hydra applications added to ActiveModel::Validations.

### Dependencies

* ActiveModel 4.x
* ActiveFedora 7.x

### Installation

Include in your Gemfile:

```ruby
gem 'hydra-validations'
```

and

```sh
bundle install
```

### Example

With a PORO, we have to include ActiveModel::Validations.  
ActiveRecord::Base and ActiveFedora::Base already include ActiveModel::Validations.

```ruby
class Foo
  include ActiveModel::Validations 
  include Hydra::Validations
  attr_accessor :field
  validates :field, single_cardinality: true
end

> Foo.validators
 => [#<Hydra::Validations::SingleCardinalityValidator:0x007fb91d1e9460 @attributes=[:field], @options={}>] 
> f = Foo.new
 => #<Foo:0x007fb91d1c9188> 
> f.field = "foo"
 => "foo" 
> f.valid?
 => true 
> f.field = ["foo"]
 => ["foo"] 
> f.valid?
 => true 
> f.field = ["foo", "bar"]
 => ["foo", "bar"] 
> f.valid?
 => false 
```
