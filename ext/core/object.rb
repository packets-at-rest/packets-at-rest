# https://github.com/packets-at-rest/packets-at-rest/issues/2
# Ruby 1.9.x we need to polyfil the 2.x method of const_get
# http://stackoverflow.com/questions/3163641/get-a-class-by-name-in-ruby

class Object
  def self.const_get19(str)

    if RUBY_VERSION > '2.0.0'
      return Object.const_get(str)
    else
      str.split('::').inject(Object) do |mod, class_name|
        return mod.const_get(class_name)
      end
    end

  end
end
