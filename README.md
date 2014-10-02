hydra-validations
=======================

[![Build Status](https://travis-ci.org/projecthydra-labs/hydra-validations.svg?branch=master)](https://travis-ci.org/projecthydra-labs/hydra-validations)
[![Gem Version](https://badge.fury.io/rb/hydra-validations.svg)](http://badge.fury.io/rb/hydra-validations)

Custom validators based on ActiveModel::Validations, developed for Hydra applications.

## Dependencies

* Ruby >= 1.9.3
* ActiveModel 4.x

ActiveFedora 7.x is a run-time dependency of the UniquenessValidator only, and is not provided by this gem.

## Installation

Include in your Gemfile:

```ruby
gem 'hydra-validations'
```

and

```sh
bundle install
```

## Why?

- Metadata values are (often) arrays (XML or RDF).
- ActiveModel validators don't distinguish between array values and scalar values.
- We want validators that validate each member of an array value.

### Example: PORO with ActiveModel::Validations

```ruby
class Validatable
  include ActiveModel::Validations
  attr_accessor :type
  validates_inclusion_of :type, in: %w(text image audio video)
end

>> record = Validatable.new
>> record.type = "text"
>> record.valid?
=> true

>> record.type = ["text", "image"]
>> record.valid?
=> false # not what we want :(

# now let's add Hydra::Validations ...

>> Validatable.include Hydra::Validations
>> Validatable.clear_validators!
>> Validatable.validates_inclusion_of :type, in: %w(text image audio video)

>> record = Validatable.new
>> record.type = ["text", "image"]
>> record.valid?
=> true # Yay!

>> record.type = ["text", "newspaper"]
>> record.valid?
=> false

# tailors error message to specific invalid array value
>> puts record.errors.full_messages
Type value "newspaper" is not included in the list
```

### Example: ActiveTriples::Resource

```ruby
class MyResource < ActiveTriples::Resource
  # ActiveTriples::Resource includes ActiveModel::Validations
  property :type, predicate: RDF::DC.type
  validates_inclusion_of :type, in: %w(text image audio video)
end

>> resource = MyResource.new
=> #<MyResource:0x3fd152026774(default)>
>> resource.type = "text"
=> "text"
>> resource.valid?
=> false # Huh? Oh yeah, resource.type is actually an array ...
>> resource.type
=> ["text"]

>> MyResource.clear_validators!
>> MyResource.include Hydra::Validations
>> MyResource.validates_inclusion_of :type, in: %w(text image audio video)
=> [Hydra::Validations::InclusionValidator]

>> resource = MyResource.new
=> #<MyResource:0x3fd150fe6be8(default)>
>> resource.type = "text"
=> "text"
>> resource.valid?
=> true # Yay!

>> resource.type << "newspapers"
>> resource.type
=> ["text", "newspapers"]
>> resource.valid?
=> false
>> puts resource.errors.full_messages
Type value "newspapers" is not included in the list
```

## EnumerableBehavior Mixin

`Hydra::Validations::EnumerableBehavior` is a mixin for an `ActiveModel::EachValidator` that validates each member of an enumerable value.  See the [FormatValidator](#formatvalidator) and [InclusionValidator](#inclusionvalidator) below for examples.

EnumerableBehavior overrides `validate_each(record, attribute, value)` calling `super(record, attribute, member)` for each member of an enumerable value (i.e., responds to `:each`).  The module "fixes" any error messages to include the specific member that failed validation -- for example, `"is invalid"` becomes `"value \"foo1\" is invalid"`, so the full message `"Identifier is invalid"` becomes `"Identifer value \"foo1\" is invalid"`.

**allow_nil, allow_blank, and allow_empty**

With EnumerableBehavior, validation of non-enumerables is unchanged (`validate_each` simply returns `super`); however, the validator options `allow_nil` and `allow_blank` *apply only to the original value* (the enumerable) and not to its members. For example, the value `[""]` with the option `allow_blank: true` will *not* bypass validation. As a result, empty enumerables will fail validation unless `allow_blank` is true or the special enumerable option `allow_empty` is true (that option does not bypass validation for non-enumerables that respond to `:empty?`, e.g., empty strings).

## Validators

See also the source code and spec tests.

### FormatValidator

Extends `ActiveModel::Validations::FormatValidator`, adding EnumerableBehavior.

See `ActiveModel::Validations::FormatValidator` for usage and options.

```ruby
class FormatValidatable
  include ActiveModel::Validations # required if not already included in class
  include Hydra::Validations
  attr_accessor :field
  validates :field, format: { with: /\A[[:alpha:]]+\Z/ }
  # ... or
  # validates_format_of :field, with: /\A[[:alpha:]]+\Z/
end

>> record = FormatValidatable.new
=> #<FormatValidatable:0x007fe3cc0ece70>
>> record.field = "foo"
=> "foo"
>> record.valid?
=> true
>> record.field = ["foo"]
=> ["foo"]
>> record.valid?
=> true
>> record.field = ["foo", "bar"]
=> ["foo", "bar"]
>> record.valid?
=> true
>> record.field = ["foo1", "bar2"]
=> ["foo1", "bar2"]
>> record.valid?
=> false
>> puts record.errors.full_messages
Field value "foo1" is invalid
Field value "bar2" is invalid
```

### InclusionValidator

Extends `ActiveModel::Validations::InclusionValidator`, adding EnumerableBehavior.

See `ActiveModel::Validations::InclusionValidator` for usage and options.

```ruby
class InclusionValidatable
  include ActiveModel::Validations # required if not already included in class
  include Hydra::Validations
  attr_accessor :field
  validates :field, inclusion: { in: ["foo", "bar", "baz"] }
  # or using helper method ...
  # validates_inclusion_of :field, in: ["foo", "bar", "baz"]
end

>> record = InclusionValidatable.new
=> #<InclusionValidatable:0x007fe3cbc40098>
>> record.field = "foo"
=> "foo"
>> record.valid?
=> true
>> record.field = "foo1"
=> "foo1"
>> record.valid?
=> false
>> record.field = ["foo"]
=> ["foo"]
>> record.valid?
=> true
>> record.field = ["foo", "bar"]
=> ["foo", "bar"]
>> record.valid?
=> true
>> record.field = ["foo", "bar1", "baz"]
=> ["foo", "bar1", "baz"]
>> record.valid?
=> false
>> puts record.errors.full_messages
Field value "bar1" is not included in the list
```

### UniquenessValidator

Validates the uniqueness of an attribute based on a Solr index query.

Intended for ActiveFedora 7.x.

```ruby
class UniquenessValidatable < ActiveFedora::Base
  include Hydra::Validations # ActiveFedora::Base includes ActiveModel::Validations
  has_metadata name: 'descMetadata', type: ActiveFedora::QualifiedDublinCoreDatastream
  has_attributes :title, datastream: 'descMetadata', multiple: false
  # Can use with multi-value attributes, but single cardinality is required.
  has_attributes :source, datastream: 'descMetadata', multiple: true
  validates :source, uniqueness: { solr_name: "source_ssim" }
  # ... or using helper method
  validates_uniqueness_of :title, solr_name: "title_ssi"
end
```

### CardinalityValidator

Validates the cardinality of the attribute value. 

CardinalityValidator extends `ActiveModel::Validations::LengthValidator` and
"tokenizes" values with `Array.wrap(value)`.  The "cardinality" of the value
is therefore the length the array. Accordingly,

- `nil` and empty enumerables have cardinality 0
- scalar values (including empty string) have cardinality 1.

CardinalityValidator customizes the `:wrong_length`, `:too_short` and `:too_long` messages
of LengthValidator to use language appropriate to cardinality. You can also override these 
options.

```ruby
class CardinalityValidatable
  include ActiveModel::Validations # required if not already included in class
  include Hydra::Validations
  attr_accessor :field
  validates :field, cardinality: { is: 1 }
  # or with helper method ...
  # validates_cardinality_of :field, is: 1
  # or, for single cardinality (same as above) ...
  # validates_single_cardinality_of :field
end

>> record = CardinalityValidatable.new
=> #<CardinalityValidatable:0x007fe3cbc632c8>
>> record.field = "foo"
=> "foo"
>> record.valid?
=> true
>> record.field = ["foo"]
=> ["foo"]
>> record.valid?
=> true
>> record.field = ["foo", "bar"]
=> ["foo", "bar"]
>> record.valid?
=> false
>> puts record.errors.full_messages
Field has the wrong cardinality (should have 1 value(s))
```
