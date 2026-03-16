param environment string
param location string = 'East US'

module appServiceModule 'modules/app-service.bicep' = {
  name: 'appServiceDeployment'
  params: {
    appServiceName: 'customer-a-${environment}-app'
    location: location
  }
}

module keyVaultModule 'modules/key-vault.bicep' = {
  name: 'keyVaultDeployment'
  params: {
    keyVaultName: 'customer-a-${environment}-kv'
    location: location
  }
}

module vnetModule 'modules/vnet.bicep' = {
  name: 'vnetDeployment'
  params: {
    vnetName: 'customer-a-${environment}-vnet'
    location: location
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${appName}-plan'
  location: location
  sku: {
    name: 'F1'
    tier: 'Free'
  }
}

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
  }
}