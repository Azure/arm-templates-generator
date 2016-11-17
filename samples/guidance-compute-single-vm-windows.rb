require 'json'
require 'arm_templates'
require 'helpers'

template = Azure::ARM::Template.create do
  virtual_machine 'server0' do
    image Azure::ARM::Compute::VirtualMachine::WINDOWS_SQL_SERVER_2014
  end
end

template.save 'template'
