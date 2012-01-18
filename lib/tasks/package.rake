desc "Package Jammit Assets"
require "jammit"
task :package do 
  Jammit.package!
end