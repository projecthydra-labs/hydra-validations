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

See also the source code andn spec tests.

### UniquenessValidator (ActiveFedora)

```ruby
class Validatable < ActiveFedora::Base
  include Hydra::Validations
  has_metadata name: 'descMetadata', type: ActiveFedora::QualifiedDublinCoreDatastream
  has_attributes :title, datastream: 'descMetadata', multiple: false
  # Can use with multi-value attributes, but single cardinality is required.
  # See SingleCardinalityValidator below.
  has_attributes :source, datastream: 'descMetadata', multiple: true

  # validates_uniqueness_of helper method
  validates_uniqueness_of :title, solr_name: "title_ssi"

  # Using `validates' with options
  validates :source, uniqueness: { solr_name: "subject_ssim" }
end
```

### SingleCardinalityValidatory (Can be used with POROs)

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
