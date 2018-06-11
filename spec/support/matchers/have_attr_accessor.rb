RSpec::Matchers.define :have_attr_accessor do |attribute_name|
  match do |model|
    model.respond_to?(attribute_name) &&
    model.respond_to?("#{attribute_name}=")
  end

  failure_message do |model|
    "expected attr_accessor for #{attribute_name} on #{model}"
  end

  failure_message_when_negated do |model|
    "expected attr_accessor for #{attribute_name} not to be defined on #{model}"
  end

  description do
    "assert there is an attr_accessor of the given name on the supplied object"
  end
end
