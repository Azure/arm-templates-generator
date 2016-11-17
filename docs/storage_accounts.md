# Azure Storage Accounts

One of the simplest Azure resources is the storage account, which has very few properties. Essentially, you need to come up with a name and what kind of storage account it is (i.e., what SLA it follows).

For storage accounts, setting the name right is important, since it becomes part of the DNS name of the storage service. Therefore it needs to be unique not just within the resource group or subscription, it needs to be globally
unique. If you don't set the name, a random one will be used.

In this example, an account name is picked at random, and the storage account type is set to 'Standard LRS'.

```
template = Azure::ARM::Template.create do

  storage_account do
    account_type Azure::ARM::StorageAccount::Standard_LRS
  end
  
end
```
`Azure::ARM::StorageAccount::Standard_LRS` is one of a set of constants added for convenience. The available account type constants are defined as:
```
Standard_LRS = 'Standard_LRS'
Standard_ZRS = 'Standard_ZRS'
Standard_GRS = 'Standard_GRS'
Standard_RAGRS = 'Standard_RAGRS'
Premium_LRS = 'Premium_LRS'
```	

To set the account name, pass in a string or ARM [expression](expressions.md) to the `storage_account` method:

```
  storage_account 'mystorageaccount' { ... }
  
  storage_account concat(uniqueString(resourceGroup().id),'accnt') { ... }
```
