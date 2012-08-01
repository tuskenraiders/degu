require 'degu/renum/enumerated_value'

module Degu
  module Renum
    module EnumeratedValueTypeFactory
      class << self
        def create(nest, type_name = nil, values = [], &block)
          klass = create_class nest, type_name
          create_values klass, values, &block
          klass
        end

        def create_class(nest, type_name = nil)
          klass = Class.new EnumeratedValue
          if type_name
            type_name = type_name.to_s.gsub(/(?:\A|_)(.)/) { $1.upcase }
            nest.const_set(type_name, klass)
          end
          klass
        end

        def create_values(klass, values, &block)
          setup_for_definition_in_block(klass) unless values
          klass.class_eval &block if block_given?
          if values
            values.each { |name| klass.const_set(name, klass.new(name)) }
          else
            begin
              klass.block_defined_values.each do |value_name, init_args, instance_block|
                value = klass.new(value_name)
                klass.const_set(value_name, value)
                value.instance_eval &instance_block if instance_block
                value.init *init_args if value.respond_to? :init
              end
            ensure
              teardown_from_definition_in_block(klass)
            end
          end
          klass.values.freeze
        end

        def setup_for_definition_in_block(klass)
          klass.class_eval do
            def self.block_defined_values
              @block_defined_values ||= []
            end

            def self.method_missing(value_name, *init_args, &instance_block)
              block_defined_values << [value_name, init_args, instance_block]
            end
          end
        end

        def teardown_from_definition_in_block(klass)
          class << klass
            remove_method :block_defined_values
            remove_method :method_missing
          end
        end
      end
    end
  end
end
