targetScope = 'resourceGroup'

param serverName string

param databaseName string

resource server 'Microsoft.DBforMySQL/flexibleServers@2023-06-30' existing = {
  name: serverName
}

resource database 'Microsoft.DBforMySQL/flexibleServers/databases@2023-06-30' = {
  parent: server
  name: databaseName
  properties: {
    charset: 'utf8'
    collation: 'utf8_general_ci'
  }
}

output id string = database.id
