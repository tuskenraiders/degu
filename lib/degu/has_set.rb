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
          enum_class = options.has_key?(:enum_class) ? options[:enum_class] : Object.const_get(set_name.to_s.camelcase)
        rescue NameError => ne
          raise NameError, "There ist no class to take the set entries from (#{ne.message})."
        end

        # Extend enum_class with field_name method
        enum_class.class_eval <<-EOF
          def field_name
            '#{set_name.to_s.singularize}_' + self.name.underscore
          end
        EOF

        define_method("#{set_name}=") do |set_elements|
          self[set_column] = 0
          unless set_elements.blank?
            if set_elements.kind_of? String
              set_elements = set_elements.split(",").collect do |element|
                element.strip!
                enum_class.const_get(element)
              end
            end
            [set_elements].flatten.each do |element|
              unless element.kind_of? enum_class
                raise ArgumentError, "You must provide an element of the #{enum_class} Enumeration. You provided an element of the class #{element.class}."
              end

              2**element.bitfield_index & self[set_column] == 2**element.bitfield_index ? next : self[set_column] += 2**element.bitfield_index
            end
          end
        end

        define_method(set_name) do
          if self[set_column] == 0
            return []
          else
            set_elements = enum_class.values.inject([]) do |set_elements, enum_element|
              set_elements << enum_element if send("#{set_name.to_s.singularize}_#{enum_element.name.underscore}?")
              set_elements
            end
            # special to_s method for element-array
            class <<set_elements
              def to_s
                self.collect { |element| "#{element.name}" }.join(", ")
              end
            end
            return set_elements
          end
        end

        # TODO: This should be a class method
        define_method("available_#{set_name.to_s}") do
          self.methods.grep(/#{set_name.to_s.singularize}_\w+[^\?=]$/).sort.map(&:to_s)
        end

        enum_class.values.each do |enum|
          define_method("#{set_name.to_s.singularize}_#{enum.name.underscore}?") do
            2**enum.bitfield_index & self[set_column] == 2**enum.bitfield_index ? true : false
          end

          alias_method :"#{set_name.to_s.singularize}_#{enum.name.underscore}", :"#{set_name.to_s.singularize}_#{enum.name.underscore}?"

          define_method("#{set_name.to_s.singularize}_#{enum.name.underscore}=") do |true_or_false|
            current_value = (2**enum.bitfield_index & self[set_column] == 2**enum.bitfield_index)
            true_or_false = true  if true_or_false.to_s == "true" || (true_or_false.respond_to?(:to_i) && true_or_false.to_i == 1)
            true_or_false = false if true_or_false.to_s == "false" || (true_or_false.respond_to?(:to_i) && true_or_false.to_i == 0)

            if current_value != true_or_false
              true_or_false ? self[set_column] += 2**enum.bitfield_index : self[set_column] -= 2**enum.bitfield_index
            end
          end
        end
      end
    end

    def self.included(receiver)
      receiver.extend         ClassMethods
    end

  end
end
