
module Azure::ARM

  class Template

    include Azure::ARM::PredefinedExpressions

    attr_accessor :resources

    def initialize(location = 'West US')
      @parameters = {}
      @variables = {}
      @resources = []
      @validators = []
    end

    CONTENTVERSION = '1.0.0.0'

    def self.create(location = 'West US',&block)

      template = Template.new location

      template.instance_exec(&block) if block

      template
    end

    def configure(&block)

      self.instance_exec(&block) if block

      self

    end

    def template_validation_rule(&block)
      @validators.push [Azure::ARM::Template, block] if block
    end

    def resource_validation_rule(resource_type, &block)
      @validators.push [resource_type, block] if block
    end

    def to_template

      @validators.each do |type, block|

        if type == Azure::ARM::Template
          block.call
        else
          find_resources(type).each do |rsrc|
            block.call rsrc
          end
        end

      end

      data = { :$schema => 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#',
               :contentVersion => CONTENTVERSION}

      resources.each do |r|
        r.finalize
      end

      resources.sort! { |a,b| a.sort_order <=> b.sort_order }

      add_parameters(data)
      add_variables(data)
      add_resources(data)

      data
    end

    def to_json
      JSON.pretty_generate self.to_template
    end

    def find_resource(type,name=nil)
      @resources.find {|r| (r.is_a? type) and (name.nil? or name == r.name )}
    end

    def find_resources(type)
      @resources.find_all {|r| type.nil? or (r.is_a? type)}
    end

    def add_variable(name, value)
      @variables[name.to_sym] = value unless @variables[name.to_sym]
      variables(name)
    end

    def add_parameter(name, description)
      @parameters[name.to_sym] = description unless @parameters[name.to_sym]
      parameters(name)
    end

    def variable(name)
      variables(name) if @variables.has_key? name.to_sym
    end

    def parameter(name)
      parameters(name) if @parameters.has_key? name.to_sym
    end

    # Generates two files: one containing the template data, one containing the parameter values with defaults
    # provided by the second argument.
    #
    def save(name, parameter_values=nil)

      param_doc = { :'$schema' => 'http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#',
                    contentVersion: '1.0.0.0',
                    parameters: parameter_values}

      File.open("#{name}.parameters.json", 'w') do |file|
        file.write(JSON.pretty_generate param_doc)
      end

      File.open("#{name}.json", 'w') do |file|
        file.write(JSON.pretty_generate self.to_template)
      end
    end

    private

    def add_parameters(data)

      params = Hash.new
      if @parameters.size > 0
        @parameters.each do |p|
          name = p[0]
          params[name] = p[1]
        end
      end
      data['parameters'] = params
    end

    def add_variables(data)

      if @variables.size > 0
        variables = Hash.new

        @variables.each do |p|
          name = p[0]
          variables[name] = p[1]
        end

        data['variables'] = variables
      end
    end

    def add_resources(data)
      res = Array.new
      data['resources'] = res
      @resources.each do |r|
        res.push r.to_h
      end
    end

  end

end