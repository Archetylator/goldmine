require "bundler/setup"
Bundler.setup

%w{goldmine}.each { |x| require x }

Dir[Goldmine.base_dir.join("spec", "support", "**", "*.rb")].each { |f| require f }

RSpec.configure do |c|
  c.include TempFile
  c.mock_with :rspec
end