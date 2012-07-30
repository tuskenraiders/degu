require 'forwardable'
begin
  require 'json'
rescue LoadError
end

module Degu
  module Renum

    # This is the superclass of all enumeration classes.
    # An enumeration class is Enumerable over its values and exposes them by numeric index via [].
    # Values are also comparable, sorting into the order in which they're declared.
    class EnumeratedValue

      class << self
        include Enumerable
        extend Forwardable

        def_delegators :values, :first, :last, :each

        # Returns an array of values in the order they're declared.
        def values
          @values ||= []
        end

        alias all values

        def names
          all.map(&:name)
        end

        def underscored_names
          all.map(&:underscored_name)
        end

        def field_names
          all.map(&:field_name)
        end

        # This class encapsulates an enum field (аctually a method with arity == 0).
        class Field < Struct.new('Field', :name, :options, :block)
          # Returns true if the :default option was given.
          def default?
            options.key?(:default)
          end

          # Returns the value of the :default option.
          def default
            options[:default]
          end

          # Returns true if a block was given.
          def block?
            !!block
          end

          # Determine the default value for the enum value +obj+ if +options+ is
          # the options hash given to the init method.
          def default_value(obj, options)
            field_value = options[name]
            if field_value.nil?
              if default?
                default_value = default
              elsif block?
                default_value = block[obj]
              end
            else
              field_value
            end
          end

          # Returns the name as a string.
          def to_s
            name.to_s
          end

          # Returns a detailed string representation of this field.
          def inspect
            "#<#{self.class}: #{self} #{options.inspect}>"
          end
        end

        # Returns an array of all fields defined on this enum.
        def fields
          @fields ||= []
        end

        # Defines a field with the name +name+, the options +options+ and the
        # block +block+. The only valid option at the moment is :default which is
        # the default value the field is initialized with.
        def field(name, options = {}, &block)
          name = name.to_sym
          fields.delete_if { |f| f.name == name }
          fields << field = Field.new(name, options, block)
          instance_eval { attr_reader field.name }
        end

        # Returns the value with the name +name+ and returns it.
        def with_name name
          values_by_name[name.to_s]
        end

        # Returns a hash that maps names to their respective values values.
        def values_by_name
          @values_by_name ||= values.inject({}) do |memo, value|
            memo[value.name] = value
            memo
          end.freeze
        end

        # Returns the enum value for +index+. If +index+ is an Integer the
        # index-th enum value is returned. Otherwise +index+ is converted into a
        # String. For strings that start with a capital letter the with_name
        # method is used to determine the enum value with the name +index+. If
        # the string starts with a lowercase letter it is converted into
        # camelcase first, that is foo_bar will be converted into FooBar, before
        # with_name is called with this new value.
        def [](index)
          case index
          when Integer
            values[index]
          when self
            values[index.index]
          else
            name = index.to_s
            case name
            when /\A(\d+)\Z/
              return values[$1.to_i]
            when /\A[a-z]/
              name = name.gsub(/(?:\A|_)(.)/) { $1.upcase }
            end
            with_name(name)
          end
        end

        # Returns the enum instance stored in the marshalled string +string+.
        def _load(string)
          with_name Marshal.load(string)
        end

        if defined?(::JSON)
          # Fetches the correct enum determined by the deserialized JSON
          # document.
          def json_create(data)
            JSON.deep_const_get(data[JSON.create_id])[data['name']]
          end
        end
      end

      include Comparable

      # Name of this enumerated value as a string.
      attr_reader :name

      # Index of this enumerated value as an integer.
      attr_reader :index

      alias_method :id, :index

      alias_method :bitfield_index, :index

      def underscored_name
        name.underscore
      end

      def field_name
        "#{self.class.name.underscore.singularize}_#{underscored_name}"
      end

      # Creates an enumerated value named +name+ with a unique autoincrementing
      # index number.
      def initialize name
        @name = name.to_s.freeze
        @index = self.class.values.size
        self.class.values << self
      end

      # This is the standard init method method which has an arbitrary number of
      # arguments. If the last argument is a Hash and its keys are defined fields
      # their respective values will be used to initialize the fields. If you
      # want to use this method from an enum and define your own custom init
      # method there, don't forget to call super from your method.
      def init(*args)
        if Hash === options = args.last
          for field in self.class.fields
            instance_variable_set "@#{field}", field.default_value(self, options)
          end
        end
      end

      # Returns the fully qualified name of the constant referring to this value.
      # Don't override this if you're using Renum with the constantize_attribute
      # plugin, which relies on this behavior.
      def to_s
        "#{self.class}::#{name}"
      end

      # Sorts enumerated values into the order in which they're declared.
      def <=> other
        index <=> other.index
      end

      # Returns a marshalled string for this enum instance.
      def _dump(limit = -1)
        Marshal.dump(name, limit)
      end

      if defined?(::JSON)
        # Set the given fields in the +obj+ hash
        def set_fields(obj, fields)
          fields.each do |f|
            name = f.name
            value = instance_variable_get("@#{name}")
            value.nil? and next
            obj[name] = value
          end
        end

        # Returns an enum (actually more a reference to an enum) serialized as a
        # JSON document.
        def as_json(opts = {}, *a)
          opts ||= {}
          obj = {
            JSON.create_id => self.class.name,
            :name          => name,
          }
          case fields_opt = opts[:fields]
          when nil, false
          when true
            set_fields obj, self.class.fields
          when Array
            fields_opt = fields_opt.map(&:to_sym)
            set_fields obj, self.class.fields.select { |field| fields_opt.include?(field.name) }
          else
            raise ArgumentError, "unexpected fields option #{fields_opt.inspect}"
          end
          obj.as_json(opts)
        end

        def to_json(opts, *a)
          obj = as_json(opts)
          opts.respond_to?(:fields) and opts.delete(:fields)
          obj.to_json(opts, *a)
        end
      end
    end
  end
end
