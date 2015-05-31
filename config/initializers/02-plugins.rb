module PacketsAtRest

  class PluginNotFound < StandardError; end
  class PluginRequirementError < StandardError; end

  # Base class for Redmine plugins.
  # Plugins are registered using the <tt>register</tt> class method that acts as the public constructor.
  #
  #   PacketsAtRest::Plugin.register :example do
  #     name 'Example plugin'
  #     author 'John Smith'
  #     description 'This is an example plugin for Redmine'
  #     version '0.0.1'
  #     settings :default => {'foo'=>'bar'}, :partial => 'settings/settings'
  #   end
  #
  # === Plugin attributes
  #

  class Plugin
    cattr_accessor :directory
    self.directory = File.join(File.dirname(__FILE__), 'plugins')

    @registered_plugins = {}
    @used_partials = {}

    class << self
      attr_reader :registered_plugins
      private :new

      def def_field(*names)
        class_eval do
          names.each do |name|
            define_method(name) do |*args|
              args.empty? ? instance_variable_get("@#{name}") : instance_variable_set("@#{name}", *args)
            end
          end
        end
      end
    end
    def_field :name, :description, :url, :author, :author_url, :version, :settings, :directory
    attr_reader :id

    # Plugin constructor
    def self.register(id, &block)
      p = new(id)
      p.instance_eval(&block)

      # Set a default name if it was not provided during registration
      p.name(id.to_s) if p.name.nil?

      # Adds the app/{controllers,helpers,models} directories of the plugin to the autoload path
      #Dir.glob File.expand_path(File.join(p.directory, 'app', '{controllers,helpers,models}')) do |dir|
      #    ActiveSupport::Dependencies.autoload_paths += [dir]
      #end
      registered_plugins[id] = p

    end

    # Returns an array of all registered plugins
    def self.all
      registered_plugins.values.sort
    end

    # Finds a plugin by its id
    # Returns a PluginNotFound exception if the plugin doesn't exist
    def self.find(id)
      registered_plugins[id.to_sym] || raise(PluginNotFound)
    end

    def self.load
      Dir.glob(File.join(self.directory, '*')).sort.each do |directory|
        if File.directory?(directory)
          lib = File.join(directory, "lib")
          if File.directory?(lib)
            $:.unshift lib
            ## Do something
            # ActiveSupport::Dependencies.autoload_paths += [lib]
          end
          initializer = File.join(directory, "init.rb")
          if File.file?(initializer)
            require initializer
          end
        end
      end
    end

    def initialize(id)
      @id = id.to_sym
    end

    def to_json
        {
            :id => @id,
            :name => @name,
            :description => @description,
            :url => @url,
            :author => @author,
            :author_url => @author_url,
            :version => @version,
            :settings => @settings,
            :directory =>  @directory
        }.to_json
    end

    def <=>(plugin)
      self.id.to_s <=> plugin.id.to_s
    end

    # Sets a requirement on Redmine version
    # Raises a PluginRequirementError exception if the requirement is not met
    #
    # Examples
    #   # Requires Redmine 0.7.3 or higher
    #   requires_packetsatrest :version_or_higher => '0.7.3'
    #   requires_packetsatrest '0.7.3'
    #
    #   # Requires Redmine 0.7.x or higher
    #   requires_packetsatrest '0.7'
    #
    #   # Requires a specific Redmine version
    #   requires_packetsatrest :version => '0.7.3'              # 0.7.3 only
    #   requires_packetsatrest :version => '0.7'                # 0.7.x
    #   requires_packetsatrest :version => ['0.7.3', '0.8.0']   # 0.7.3 or 0.8.0
    #
    #   # Requires a Redmine version within a range
    #   requires_packetsatrest :version => '0.7.3'..'0.9.1'     # >= 0.7.3 and <= 0.9.1
    #   requires_packetsatrest :version => '0.7'..'0.9'         # >= 0.7.x and <= 0.9.x
    def requires_packetsatrest(arg)
      arg = { :version_or_higher => arg } unless arg.is_a?(Hash)
      arg.assert_valid_keys(:version, :version_or_higher)

      current = PacketsAtRest::VERSION
      arg.each do |k, req|
        case k
        when :version_or_higher
          raise ArgumentError.new(":version_or_higher accepts a version string only") unless req.is_a?(String)
          unless _compare_versions(req, current) <= 0
            raise PluginRequirementError.new("#{id} plugin requires PacketsAtRest #{req} or higher but current is #{current}")
          end
        when :version
          req = [req] if req.is_a?(String)
          if req.is_a?(Array)
            unless req.detect {|ver| _compare_versions(ver, current) == 0}
              raise PluginRequirementError.new("#{id} plugin requires one the following PacketsAtRest versions: #{req.join(', ')} but current is #{current}")
            end
          elsif req.is_a?(Range)
            unless _compare_versions(req.first, current) <= 0 && _compare_versions(req.last, current) >= 0
              raise PluginRequirementError.new("#{id} plugin requires a PacketsAtRest version between #{req.first} and #{req.last} but current is #{current}")
            end
          else
            raise ArgumentError.new(":version option accepts a version string, an array or a range of versions")
          end
        end
      end
      true
    end

    def _compare_versions(requirement, current)
      requirement = _sematic_version(requirement)
      current = _sematic_version(current)
      requirement <=> current.slice(0, requirement.size)
    end

    # splits a sematic version string into an array of integers
    # "0.0.1".split('.').collect(&:to_i)
    # => [0, 0, 1]
    def _sematic_version(version)
        version.split('.').collect(&:to_i)
    end
    private :_compare_versions, :_sematic_version

    # Sets a requirement on a Redmine plugin version
    # Raises a PluginRequirementError exception if the requirement is not met
    #
    # Examples
    #   # Requires a plugin named :foo version 0.7.3 or higher
    #   requires_packetsatrest_plugin :foo, :version_or_higher => '0.7.3'
    #   requires_packetsatrest_plugin :foo, '0.7.3'
    #
    #   # Requires a specific version of a Redmine plugin
    #   requires_packetsatrest_plugin :foo, :version => '0.7.3'              # 0.7.3 only
    #   requires_packetsatrest_plugin :foo, :version => ['0.7.3', '0.8.0']   # 0.7.3 or 0.8.0
    def requires_packetsatrest_plugin(plugin_name, arg)
      arg = { :version_or_higher => arg } unless arg.is_a?(Hash)
      arg.assert_valid_keys(:version, :version_or_higher)

      plugin = Plugin.find(plugin_name)
      current = _sematic_version(plugin.version)

      arg.each do |k, v|
        v = [] << v unless v.is_a?(Array)
        versions = v.collect {|s| _sematic_version(s)}
        case k
        when :version_or_higher
          raise ArgumentError.new("wrong number of versions (#{versions.size} for 1)") unless versions.size == 1
          unless (current <=> versions.first) >= 0
            raise PluginRequirementError.new("#{id} plugin requires the #{plugin_name} plugin #{v} or higher but current is #{current.join('.')}")
          end
        when :version
          unless versions.include?(current.slice(0,3))
            raise PluginRequirementError.new("#{id} plugin requires one the following versions of #{plugin_name}: #{v.join(', ')} but current is #{current.join('.')}")
          end
        end
      end
      true
    end
  end
end
