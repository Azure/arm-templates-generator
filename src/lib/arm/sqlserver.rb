module Azure::ARM::Sql
  #
  # Microsoft.Sql/servers
  #
  class Server < Azure::ARM::ResourceBase

    def prepare
      configure do
        resources name: 'AllowAllWindowsAzureIps',
                  start_ip_address: '0.0.0.0',
                  end_ip_address: '0.0.0.0'
      end
    end

    class Configurator < Azure::ARM::ResourceConfigurator

      def database(init=nil, &block)
        if init.nil?
          init = Hash.new
        end
        if !init.is_a? Hash
          name = init
          init = {name: name}
        end
        db = DatabasesBase.new @parent, init
        db.path = 'resources'
        init[:properties] = db
        dbItem = Azure::ARM::Sql::ServersResourcesItem0.new @parent, init
        dbItem.path = 'resources'
        db.configure &block

        @parent.resources = Array.new if @parent.resources.nil?
        @parent.resources.push dbItem
      end

      def firewall_rule(init=nil, &block)
        if init.nil?
          init = Hash.new
        end
        if !init.is_a? Hash
          name = init
          init = {name: name}
        end
        rule = FirewallrulesBase.new @parent, init
        rule.path = 'resources'
        init[:properties] = rule
        ruleItem = Azure::ARM::Sql::ServersResourcesItem1.new @parent, init
        ruleItem.path = 'resources'
        rule.configure &block

        @parent.resources = Array.new if @parent.resources.nil?
        @parent.resources.push ruleItem
      end

    end

    def generate_name(prefix)
      name = template.add_variable 'sqlsrvr'+@@number.to_s,
                                   concat("sqlsrvr", uniqueString(resourceGroup().id), @@number)
      @@number += 1
      name
    end

    private

    @@number = 0

  end

end
