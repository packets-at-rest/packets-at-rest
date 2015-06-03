module PacketsAtRest
    module NodeAccessToken
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

                if api_file_contains?(user_key)
                    access_granted = true
                else
                    access_granted =  false
                end

                access_granted ? success!(access_granted): fail!("Could not log in")
            end

            def api_file_contains?(api_key)
              begin
                h = JSON.parse(File.read(PacketsAtRest::APIFILE))
                h[api_key] ? true : false
              rescue
                false
              end
            end
        end
    end
end
