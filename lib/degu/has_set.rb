$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'active_support'
require 'active_record'
module Degu
  module HasSet
    VERSION = '0.0.4'

    module ClassMethods
      # Use like this:
      #
      #   class Person < ActiveRecord::Base
      #     has_set :interests
      #   end
      def has_set(set_name, options = {})

        set_column = options.has_key?(:column_name) ? options[:column_name].to_s : "#{set_name}_bitfield"

        begin
          enum_class = options.has_key?(:enum_class) ? options[:enum_class] : set_name.to_s.camelcase.constantize
        rescue NameError => ne
          raise NameError, "There ist no class to take the set entries from (#{ne.message})."
        end

        # Extend enum_class with field_name method
        enum_class.class_eval <<-EOF
          def field_name
            '#{set_name.to_s.singularize}_' + self.name.underscore
          end
        EOF

        define_method("#{set_name}=") do |argument_value|
          self[set_column] = 
            unless argument_value.nil?
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
              if set_elements.any? { |set_element| set_element.nil? }
                raise ArgumentError, "element #{argument_value.inspect} contains invalid elements: #{invalid_set_elements.inspect}"
              end
              value = 0
              set_elements.each do |set_element|
                mask = 1 << set_element.bitfield_index
                if mask & value == mask
                  next
                else
                  value |= mask
                end
              end
              value
            end
        end

        define_method(set_name) do
          value = self[set_column]
          case
          when value.blank?
            ;;
          when value.zero?
            []
          else
            set_elements = enum_class.values.select do |enum_element|
              send("#{set_name.to_s.singularize}_#{enum_element.name.underscore}?")
            end
            # special to_s method for element-array
            class << set_elements
              def to_s
                map(&:name) * ', '
              end
            end
            set_elements
          end
        end

        # TODO: This should be a class method
        define_method("available_#{set_name}") do
          self.methods.grep(/#{set_name.to_s.singularize}_\w+[^\?=]$/).sort.map(&:to_s)
        end

        enum_class.values.each do |enum|
          define_method("#{set_name.to_s.singularize}_#{enum.name.underscore}?") do
            mask = 1 << enum.bitfield_index
            self[set_column] & mask == mask
          end

          alias_method :"#{set_name.to_s.singularize}_#{enum.name.underscore}", :"#{set_name.to_s.singularize}_#{enum.name.underscore}?"

          define_method("#{set_name.to_s.singularize}_#{enum.name.underscore}=") do |true_or_false|
            mask = 1 << enum.bitfield_index
            current_value = mask & self[set_column] == mask
            true_or_false = true  if true_or_false.to_s == "true" || true_or_false.respond_to?(:to_i) && true_or_false.to_i == 1
            true_or_false = false if true_or_false.to_s == "false" || true_or_false.respond_to?(:to_i) && true_or_false.to_i == 0

            if current_value != true_or_false
              true_or_false ? self[set_column] |= mask : self[set_column] &= ~mask
            end
          end
        end
      end
    end

    def self.included(modul)
      modul.extend(ClassMethods)
    end
  end
end
