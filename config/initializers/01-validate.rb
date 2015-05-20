require './lib/valid'

begin
    if PacketsAtRest::ROLE == :node
      raise PacketsAtRest::InValid, 'Node did not validate' unless PacketsAtRest::Valid.validate(PacketsAtRest::ROLE) == true
    elsif PacketsAtRest::ROLE == :collector
      raise PacketsAtRest::InValid, 'Collector did not validate' unless PacketsAtRest::Valid.validate(PacketsAtRest::ROLE) == true
    elsif PacketsAtRest::ROLE == :unit_test
      'unit_test'
    else
      raise 'Unknown Role'
    end
rescue Exception => e
    abort "Configurations did not validate => #{e.message}"
end
