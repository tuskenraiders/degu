$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'active_support'
require 'active_record'
module Degu
  module HasSet
    extend ActiveSupport::Concern

    module ClassMethods
      # Use like this:
      #
      #   class Person < ActiveRecord::Base
      #     has_set :interests
      #   end
      def has_set(set_name, options = {})
        set_name_singular = set_name.to_s.singularize
        set_column = options.has_key?(:column_name) ? options[:column_name].to_s : "#{set_name}_bitfield"

        begin
          enum_class = options[:class_name] || options[:enum_class] || set_name.to_s.camelcase.constantize
        rescue NameError => ne
          raise NameError, "There ist no class to take the set entries from (#{ne.message})."
        end

        define_method("#{set_name}=") do |argument_value|
          value = nil
          unless argument_value.nil?
            value = 0
            has_set_coerce_argument_value(enum_class, argument_value).each do |set_element|
              value |= 1 << set_element.bitfield_index
            end
          end
          write_set_attribute set_column, value
        end

        define_method(set_name) do
          value = read_set_attribute(set_column) or return
          set_elements = enum_class.select do |enum_element|
            mask = 1 << enum_element.bitfield_index
            value & mask == mask
          end
          # special to_s method for element-array
          class << set_elements
            def to_s
              map(&:name) * ', '
            end
          end
          set_elements
        end

        class << self; self; end.instance_eval do
          define_method("available_#{set_name}") do
            enum_class.underscored_names.map { |name| "#{set_name_singular}_#{name}" }
          end
        end
        define_method("available_#{set_name}") do
          enum_class.underscored_names.map { |name| "#{set_name_singular}_#{name}" }
        end

        enum_class.each do |enum|
          define_method("#{set_name_singular}_#{enum.underscored_name}?") do
            mask = 1 << enum.bitfield_index
            read_set_attribute(set_column) & mask == mask
          end

          alias_method :"#{set_name_singular}_#{enum.underscored_name}", :"#{set_name_singular}_#{enum.underscored_name}?"

          define_method("#{set_name_singular}_#{enum.underscored_name}=") do |true_or_false|
            mask = 1 << enum.bitfield_index
            total_value = read_set_attribute(set_column)
            current_value = mask & total_value == mask
            true_or_false = true  if true_or_false.to_s == "true" || true_or_false.respond_to?(:to_i) && true_or_false.to_i == 1
            true_or_false = false if true_or_false.to_s == "false" || true_or_false.respond_to?(:to_i) && true_or_false.to_i == 0
            if current_value != true_or_false
              write_set_attribute set_column, true_or_false ? total_value | mask : total_value & ~mask
            end
          end
        end
      end
    end

    ##
    # Just a small wrapper about the `ActiveRecord::Base#read_attribute` method, which also checks the type
    #  of the column and converts the value to an `Integer` if `String` is given.
    def read_set_attribute(attribute_name)
      value = read_attribute(attribute_name)
      if column_definition = self.class.columns_hash[attribute_name.to_s] and
        column_type = column_definition.type and column_type == :string
      then
        value = value.to_i(10)
      end
      value
    end

    ##
    # Just a small wrapper about the `ActiveRecord::Base#write_attribute` method, which also checks the type
    #  of the column and converts the value to an `String` if `String` is the column type. This is needed because
    #  implicit conversion produces something like `3.4532454354325645e+17` instead of an `integer`
    def write_set_attribute(attribute_name, value)
      if column_definition = self.class.columns_hash[attribute_name.to_s] and
        column_type = column_definition.type and column_type == :string
      then
        value = value.to_s(10)
      end
      write_attribute(attribute_name, value)
    end

    ##
    # Understands the arguments as the list of enum values
    #  The argument value can be
    #    - a `string` of enum values joined by a comma
    #    - an enum constant
    #    - a `symbol` which resolves to the enum constant
    #    - an `integer` as the index of the enum class
    #  If you have just 1 value, you do not need to enclose it in an `Array`
    def has_set_coerce_argument_value(enum_class, argument_value)
      invalid_set_elements = []
      set_elements =
        if String === argument_value
          argument_value.split(',').map(&:strip)
        else
          Array(argument_value)
        end.map do |set_element|
          if result = enum_class[set_element]
            result
          else
            invalid_set_elements << set_element
            nil
          end
        end
      invalid_set_elements.empty? or
        raise ArgumentError, "element #{argument_value.inspect} contains invalid elements: #{invalid_set_elements.inspect}"
      set_elements
    end
  end
end
