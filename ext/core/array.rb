class Array
  if !([].respond_to? :to_h)
    def to_hash
      self.inject({}) { |h, (k, v)|  h[k] = v; h }
    end
    alias :to_h :to_hash
  else
    alias :to_hash :to_h
  end

  # Extracts options from a set of arguments. Removes and returns the last
  # element in the array if it's a hash, otherwise returns a blank hash.
  #
  #   def options(*args)
  #     args.extract_options!
  #   end
  #
  #   options(1, 2)        # => {}
  #   options(1, 2, a: :b) # => {:a=>:b}
  def extract_options!
    if last.is_a?(Hash) && last.extractable_options?
      pop
    else
      {}
    end
  end

end
