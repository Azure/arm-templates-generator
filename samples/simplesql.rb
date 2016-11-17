require 'json'
require 'arm_templates'
require 'helpers'

PARAMETERS = { }

template = Azure::ARM::Template.create do

  server do
    version '2.0'

    administrator_login 'niklasg'
    administrator_login_password 'Niklas1020Gustafsson'

    database 'firstDB' do
      edition 'Basic'
      max_size_bytes '104857600'
    end

    firewall_rule 'fwr1' do
      start_ip_address '1.0.0.0'
      end_ip_address '2.0.0.0'
    end

  end

end

template.save 'template', PARAMETERS