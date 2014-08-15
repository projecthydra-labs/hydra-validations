#
# SingleCardinalityValidator - validates that an enumerator value has size 0 or 1
#
#    validates :myattr, single_cardinality: true
#
class SingleCardinalityValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    if value.respond_to?(:each)
      record.errors.add(attribute, "can't have more than one value") if value.size > 1
    end
  end

end
