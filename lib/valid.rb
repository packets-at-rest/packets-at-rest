require 'rubygems'
require 'json'
require_relative '../config/config'

module PacketsAtRest

    class InValid < StandardError; end
    class InValidJSON < StandardError; end

    class Valid
        def self.validate(role)
            if role.to_sym == :collector
                begin
                    raise InValid, 'APIFile Missing' unless File.file?(APIFILE)
                    raise InValid, 'NODEFILE Missing' unless File.file?(NODEFILE)
                    raise InValidJSON, 'APIFile JSON data is incorrect' unless JSON.parse(File.read(APIFILE)).to_json
                    raise InValidJSON, 'NODEFILE JSON data is incorrect' unless JSON.parse(File.read(NODEFILE)).to_json
                    return true
                rescue => e
                    raise
                end
            elsif role.to_sym == :node
                begin
                    raise InValid unless File.file?(TCPDUMP)
                    raise InValid unless File.file?(PRINTF)
                    raise InValid unless File.directory?(CAPTUREDIR)
                    return true
                rescue => e
                    raise
                end
            elsif role.to_sym == :unit_test
                return true
            else
                raise InValid, "unknown role (#{role.to_sym}) requested to be validated"
            end
        end
    end
end
