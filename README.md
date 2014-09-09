hydra-validations
=======================

Custom validators for Hydra applications, based on ActiveModel::Validations.

[![Build Status](https://travis-ci.org/projecthydra-labs/hydra-validations.svg?branch=master)](https://travis-ci.org/projecthydra-labs/hydra-validations)
[![Gem Version](https://badge.fury.io/rb/hydra-validations.svg)](http://badge.fury.io/rb/hydra-validations)

## Dependencies

* Ruby >= 1.9.3
* ActiveModel 4.x

## Installation

Include in your Gemfile:

```ruby
gem 'hydra-validations'
```

and

```sh
bundle install
```

## EnumerableBehavior Mixin

Hydra::Validations::EnumerableBehavior is a mixin for an ActiveModel::EachValidator that validates each member of an enumerable value.  See the FormatValidator and InclusionValidator below for examples.

EnumerableBehavior overrides `validate_each(record, attribute, value)` calling `super(record, attribute, member)` for each member of an enumerable value (i.e., responds to `:each`).  The module "fixes" any error messages to include the specific member that failed validation -- for example, `"is invalid"` becomes `"value \"foo1\" is invalid"`, so the full message `"Identifier is invalid"` becomes `"Identifer value \"foo1\" is invalid"`.

**`allow_nil`, `allow_blank`, and `allow_empty`**

With EnumerableBehavior, validation of non-enumerables is unchanged (`validate_each` simply returns `super`); however, the validator options `allow_nil` and `allow_blank` *apply only to the original value* (the enumerable) and not to its members. For example, the value `[""]` with the option `allow_blank: true` will *not* bypass validation. As a result, empty enumerables will fail validation unless `allow_blank` is true or the special enumerable option `allow_empty` is true (that option does not bypass validation for non-enumerables that respond to `:empty?`, e.g., empty strings).

## Validators

See also the source code and spec tests.

### FormatValidator

Extends the ActiveModel::Validations::FormatValidator, adding EnumerableBehavior.

See documentation for ActiveModel::Validations::FormatValidator for usage and options.

```ruby
class FormatValidatable
  include ActiveModel::Validations # required if not already included in class
  include Hydra::Validations
  attr_accessor :field
  validates :field, format: { with: /\A[[:alpha:]]+\Z/ }
  # ... or
  # validates_format_of :field, with: /\A[[:alpha:]]+\Z/
end

> v = FormatValidatable.new
 => #<FormatValidatable:0x007ffc55175300> 
> v.field = ["foo", "bar"]
 => ["foo", "bar"] 
> v.valid?
 => true 
> v.field = ["foo1", "bar2"]
 => ["foo1", "bar2"] 
> v.valid?
 => false 
> v.errors[:field]
 => ["value \"foo1\" is invalid", "value \"bar2\" is invalid"] 
> v.errors.full_messages
 => ["Field value \"foo1\" is invalid", "Field value \"bar2\" is invalid"]
```

### InclusionValidator

Extends ActiveModel::Validations::InclusionValidator, adding EnumerableBehavior.

See documentation for ActiveModel::Validations::InclusionValidator for usage and options.

```ruby
class InclusionValidatable
  include ActiveModel::Validations # required if not already included in class
  include Hydra::Validations
  attr_accessor :field
  validates :field, inclusion: { in: ["foo", "bar", "baz"] }
  # or using helper method ...
  # validates_inclusion_of :field, in: ["foo", "bar", "baz"]
end

> v = InclusionValidatable.new
 => #<InclusionValidatable:0x007ffc53079318> 
> v.field = ["foo", "bar"]
 => ["foo", "bar"] 
> v.valid?
 => true 
> v.field = ["foo", "bar", "spam", "eggs"]
 => ["foo", "bar", "spam", "eggs"] 
> v.valid?
 => false 
> v.errors[:field]
 => ["value \"spam\" is not included in the list", "value \"eggs\" is not included in the list"] 
> v.errors.full_messages
 => ["Field value \"spam\" is not included in the list", "Field value \"eggs\" is not included in the list"]
```

### UniquenessValidator

Validates the uniqueness of an attribute based on a Solr index query.

Intended for ActiveFedora 7.x.

```ruby
class UniquenessValidatable < ActiveFedora::Base
  include Hydra::Validations
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

CardinalityValidator is a subclass of ActiveModel::Validations::LengthValidator which
"tokenizes" values with `Array.wrap(value)`.  The "cardinality" of the value
is the length the array. Hence,

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

> CardinalityValidatable.validators
 => [#<Hydra::Validations::CardinalityValidator:0x007fb91d1e9460 @attributes=[:field], @options={:is=>1}>] 
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
