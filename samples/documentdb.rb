require 'json'
require 'arm_templates'
require 'helpers'

PARAMETERS = { }

template = Azure::ARM::Template.create do

  database_account do
    database_account_offer_type 'Standard'
    consistency_policy default_consistency_level: 'Strong'
  end

end

template.save 'template', PARAMETERS