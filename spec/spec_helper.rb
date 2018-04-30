RSpec.configure do |c|
  c.mock_with :mocha

  if ENV['PUPPET_DEBUG']
    c.before(:each) do
      Puppet::Util::Log.level = :debug
      Puppet::Util::Log.newdestination(:console)
    end
  end
end
require 'puppetlabs_spec_helper/module_spec_helper'

