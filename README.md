hydra-validations
=======================

Custom validations for Hydra applications based on ActiveModel::Validations.

### Installation

Include in your Gemfile:

```ruby
gem 'hydra-validations'
```

and

```sh
bundle install
```

### Usage

To include helper methods:

```ruby
include Hydra::Validations
```

For example:

```ruby
validates_single_cardinality_of :my_single_valued_attr
```
