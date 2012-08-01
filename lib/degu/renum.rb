require 'degu/renum/enumerated_value_type_factory'

module Degu
  # Requiring 'renum' mixes the Renum module into both the main Object and
  # Module, so it can be called from anywhere that you might reasonably
  # define an enumeration with an implicit receiver.
  module Renum

    # Figures out whether the new enumeration will live in Object or the
    # receiving Module, then delegates to EnumeratedValueTypeFactory#create for
    # all the real work.
    def enum(type_name = nil, values = nil, &block)
      nest = self.is_a?(Module) ? self : Object
      if type_name.respond_to?(:to_ary)
        EnumeratedValueTypeFactory.create(nest, nil, type_name.to_ary, &block)
      else
        EnumeratedValueTypeFactory.create(nest, type_name, values, &block)
      end
    end
  end
end
