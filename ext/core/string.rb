class String
    # +camelize+ converts strings to UpperCamelCase.
    #
    # +camelize+ will also convert '/' to '::' which is useful for converting
    # paths to namespaces.
    #
    #   'active_model'.camelize                # => "ActiveModel"
    #   'active_model/errors'.camelize         # => "ActiveModel::Errors"
    #
    # As a rule of thumb you can think of +camelize+ as the inverse of
    # +underscore+, though there are cases where that does not hold:
    #
    #   'SSLError'.underscore.camelize # => "SslError"
    def camelize

      a = self.sub(/^[a-z\d]*/) { $&.capitalize }
      a.gsub!(/(?:_|(\/))([a-z\d]*)/i) { "#{$2.capitalize}" }
      a.gsub!('/', '::')
      a
    end

    alias_method :camelcase, :camelize

end
