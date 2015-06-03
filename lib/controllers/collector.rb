module PacketsAtRest
    module Controllers
        class Collector

            attr_reader :apifile, :nodefile

            def initialize(opts = {})
                @apifile = opts[:apifile] || PacketsAtRest::APIFILE
                @nodefile = opts[:nodefile] || PacketsAtRest::NODEFILE
            end

            def lookup_nodes_by_api_key(api_key)
              begin
                # TODO: make h a @@
                h = JSON.parse(File.read(@apifile))
                return h[api_key.to_s]
              rescue
                nil
              end
            end

            def lookup_nodeaddress_by_id(id)
              begin
                h = JSON.parse(File.read(@nodefile))
                return h[id.to_s]
              rescue
                nil
              end
            end

            def lookup_nodeaddresses
              begin
                return JSON.parse(File.read(@nodefile))
              rescue
                nil
              end
            end

            def authorized_nodes(user_api_key)
                accessible_nodes = lookup_nodes_by_api_key(user_api_key)

                if accessible_nodes.include? "0"
                  return lookup_nodeaddresses
                else
                  return lookup_nodeaddresses.keep_if { |k, v| accessible_nodes.include? k }
                end
            end

            alias_method :valid_node?, :lookup_nodeaddress_by_id
        end
    end
end
