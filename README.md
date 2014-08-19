hydra-validations
=======================

Custom validators for Hydra applications, based on ActiveModel::Validations.

[![Build Status](https://travis-ci.org/projecthydra-labs/hydra-validations.svg?branch=master)](https://travis-ci.org/projecthydra-labs/hydra-validations)
[![Gem Version](https://badge.fury.io/rb/hydra-validations.svg)](http://badge.fury.io/rb/hydra-validations)

## Dependencies

* Ruby >= 1.9.3
* ActiveModel 4.x
* ActiveFedora 7.x

## Installation

Include in your Gemfile:

```ruby
gem 'hydra-validations'
```

and

```sh
bundle install
```

## Validators

See also the source code and spec tests.

**FormatValidator** - Extends the ActiveModel version to validate the format of *each member* of an enumerable attribute value.

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

**InclusionValidator** - Extends the ActiveModel version to validate inclusion of *each member* of an enumerable attribute value.

See documentation for ActiveModel::Validations::InclusionValidator for usage and options.

```ruby
class InclusionValidatable
  include ActiveModel::Validations # required if not already included in class
  include Hydra::Validations
  attr_accessor :field
  validates :field, inclusion: { in: ["foo", "bar", "baz"] }
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

**UniquenessValidator** - Validates the uniqueness of an attribute based on a Solr index query.

```ruby
class UniquenessValidatable < ActiveFedora::Base
  include Hydra::Validations
  has_metadata name: 'descMetadata', type: ActiveFedora::QualifiedDublinCoreDatastream
  has_attributes :title, datastream: 'descMetadata', multiple: false
  # Can use with multi-value attributes, but single cardinality is required.
  # See SingleCardinalityValidator below.
  has_attributes :source, datastream: 'descMetadata', multiple: true
  validates :source, uniqueness: { solr_name: "source_ssim" }
  # ... or using helper method
  validates_uniqueness_of :title, solr_name: "title_ssi"
end
```

**SingleCardinalityValidatory** - Validates that the attribute value is a scaler or single-member enumerable.

```ruby
class Validatable
  include ActiveModel::Validations # required if not already included in class
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
