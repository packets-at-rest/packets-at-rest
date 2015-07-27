require './lib/plugin.rb'

# Require the `init.rb` for each of the plugins you want enabled here.
if PacketsAtRest::ROLE != :unit_test
  require_relative '../../plugins/par-plugin-facter/init.rb'
end
