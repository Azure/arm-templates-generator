
module Azure::ARM::Storage
  #
  # Microsoft.Storage/storageAccounts
  #
  class StorageAccount < Azure::ARM::ResourceBase

    Standard_LRS = 'Standard_LRS'
    Standard_ZRS = 'Standard_ZRS'
    Standard_GRS = 'Standard_GRS'
    Standard_RAGRS = 'Standard_RAGRS'
    Premium_LRS = 'Premium_LRS'

    def generate_name(prefix)
      name = template.add_variable 'storageAccount'+@@number.to_s,
                                   concat("strge", uniqueString(resourceGroup().id), @@number)
      @@number += 1
      name
    end

    private

    @@number = 0
  end

end

