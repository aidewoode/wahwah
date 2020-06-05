# frozen_string_literal: true

module WahWah
  module TagDelegate
    def tag_delegate(accessor, *attributes)
      attributes.each do |attr|
        define_method(attr) do
          tag = instance_variable_get(accessor)

          return super() if tag.nil?
          tag.send(attr)
        end
      end
    end
  end
end
