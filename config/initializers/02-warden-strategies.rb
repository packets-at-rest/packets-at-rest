require './lib/strategies/node_access_token.rb'
require './lib/strategies/admin_access_token.rb'

Warden::Strategies.add(:node_access_token, PacketsAtRest::NodeAccessToken::Strategy)
Warden::Strategies.add(:admin_access_token, PacketsAtRest::AdminAccessToken::Strategy)
