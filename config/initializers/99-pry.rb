if ENV['pry']
 require 'pry'
 if ENV['break']
   binding.pry
 end  
end
