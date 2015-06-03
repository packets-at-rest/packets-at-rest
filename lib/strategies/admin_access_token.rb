module PacketsAtRest
    module AdminAccessToken
        class Strategy < Warden::Strategies::Base

            def valid?
                # Validate that the access token is properly formatted.
                # Currently only checks that it's actually a string.

                # Explicit params for now.
                # request.env["API_KEY"].is_a?(String) || params['api_key'].is_a?(String)
                params['api_key'].is_a?(String)
            end

            def authenticate!
                # Explicit params for now.
                # user_key = request.env["API_KEY"] || params['api_key']
                user_key = params['api_key']

                if has_admin?(user_key)
                    access_granted = true
                else
                    access_granted =  false
                end

                access_granted ? success!(access_granted): fail!("Could not log in")
            end

            def has_admin?(api_key)
              begin
                apifile_hash = JSON.parse(File.read(PacketsAtRest::APIFILE))
                accessible_nodes = apifile_hash[api_key.to_s] || []
                return accessible_nodes.include? "0"
              rescue
                false
              end
            end
        end
    end
end
