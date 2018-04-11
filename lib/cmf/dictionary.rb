module CMF

  # Provides functionality for validating the `dictionary` argument passed to {Builder} and {Parser}.
  module Dictionary

    # Validates a dictionary, and optionally converts it from array form to
    # hash form.
    #
    # @param dictionary [Hash,Array] The dictionary mapping tag names to
    #     numbers. For example:
    #
    #         {name: 0, address: 1, email: 2}
    #
    #     Arrays will be converted to hashes with each array value mapping to
    #     its index. The following is equivalent to the above example:
    #
    #         [:name, :address, :email]
    #
    # @return [Hash] A dictionary mapping tag names to numbers.
    #
    # @raise [TypeError] if any dictionary keys are integers.
    # @raise [TypeError] if any dictionary values are not integers.
    # @raise [ArgumentError] if dictionary values are not unique.
    # @raise [ArgumentError] if any dictionary values are negative.
    def self.validate(dictionary)
      return {} if dictionary.nil?

      if dictionary.is_a? Array
        dictionary = dictionary.map.with_index {|s, i| [s, i]}.to_h
      end

      dictionary.is_a? Hash or raise TypeError, "Dictionary must be an Array or Hash"
      dictionary.keys.each do |k|
        !k.is_a?(Integer) or raise TypeError, "Invalid dictionary key #{k}. Must not be an integer"
      end
      dictionary.values.each do |v|
        v.is_a?(Integer) or raise TypeError, "Invalid dictionary value #{v}. Must all be an integer"
        v >= 0 or raise ArgumentError, "Invalid dictionary value #{v}. Must be >= 0"
      end
      dictionary.values.size == dictionary.values.uniq.size or raise ArgumentError, "Dictionary values must be unique"

      dictionary
    end
  end
end
