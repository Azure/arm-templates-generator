module Azure::ARM::DocumentDB
  #
  # Microsoft.DocumentDB: A Database Account
  #
  class DatabaseAccount < Azure::ARM::ResourceBase

    def generate_name(prefix)
      name = template.add_variable 'docdbAccount'+@@number.to_s,
                                   concat("docdb", uniqueString(resourceGroup().id), @@number)
      @@number += 1
      name
    end

    private

    @@number = 0
  end

end
