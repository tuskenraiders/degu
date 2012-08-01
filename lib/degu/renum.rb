require 'degu/renum/enumerated_value_type_factory'

module Degu
  # Requiring 'renum' mixes the Renum module into both the main Object and
  # Module, so it can be called from anywhere that you might reasonably
  # define an enumeration with an implicit receiver.
  module Renum

    # Figures out whether the new enumeration will live in Object or the
    # receiving Module, then delegates to EnumeratedValueTypeFactory#create for
    # all the real work.
    def enum(type_name = nil, values = :defined_in_block, &block)
      nest = self.is_a?(Module) ? self : Object
      EnumeratedValueTypeFactory.create(nest, type_name, values, &block)
    end
  end
end
