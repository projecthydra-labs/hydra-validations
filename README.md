hydra-validations
=======================

Custom validators for Hydra applications, based on ActiveModel::Validations.

### Dependencies

* Ruby >= 1.9.3
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
class Validatable
  include ActiveModel::Validations 
  include Hydra::Validations
  attr_accessor :field
  validates :field, single_cardinality: true
end

> Validatable.validators
 => [#<Hydra::Validations::SingleCardinalityValidator:0x007fb91d1e9460 @attributes=[:field], @options={}>] 
> v = Validatable.new
 => #<Validatable:0x007fb91d1c9188> 
> v.field = "foo"
 => "foo" 
> v.valid?
 => true 
> v.field = ["foo"]
 => ["foo"] 
> v.valid?
 => true 
> v.field = ["foo", "bar"]
 => ["foo", "bar"] 
> v.valid?
 => false 
```
