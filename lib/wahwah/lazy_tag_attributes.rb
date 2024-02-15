# frozen_string_literal: true

module WahWah
  module LazyTagAttributes
    def self.included(base)
      base.extend ClassMethods

      base.class_eval do
        instance_variable_set :@_lazy_attributes, []

        def self.inherited(subclass)
          subclass.class_eval do
            instance_variable_set :@_lazy_attributes, subclass.superclass._lazy_attributes.dup
          end
        end
      end
    end

    def load_fully
      self.class._lazy_attributes.each do |name|
        send name
      end
      nil
    end

    module ClassMethods
      def _lazy_attributes
        @_lazy_attributes
      end

      # Adapted from https://www.gregnavis.com/articles/lazy-attributes-in-ruby.html
      def lazy(name, if_closed = nil, &definition)
        variable_name = :"@#{name}"
        @_lazy_attributes.push name

        define_method(name) do
          if instance_variable_defined? variable_name
            instance_variable_get variable_name
          else
            result = begin
              instance_eval(&definition)
            rescue => error
              # We want to let parsing errors result in default values,
              # but if the user attempts to read a lazy property from
              # a file that's closed, that error should go through.
              raise if error.is_a? IOError
              if_closed
            end
            instance_variable_set variable_name, result
          end
        end
      end
    end
  end
end
