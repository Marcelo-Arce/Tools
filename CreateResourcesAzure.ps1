$resourceGroup = "Your resource group name"
$location = "your ZONE"
$stAccount = "almaceninicial"
$containerName  = "contenedorbase1"
$dataLakeName = "almacendatalake"
$dataFactoryName = "datafactorybase1";
$serverName = "serverprincipal1"
$bacpacFilename = "dbRetail.bacpac"
$adminSqlLogin = "admin"
$password = "Pasword2022"
$databaseName = "dbRetail"
$startIp = "Your IP"
$endIp = "Your IP"
$ctx = New-AzStorageContext -StorageAccountName $dataLakeName -UseConnectedAccount
$datalakein = "input"
$datalakeout = "output"

Connect-AzAccount

#STORAGE ACCOUNT & UPLOAD FILE#

$StorageHT = @{
  ResourceGroupName = $resourceGroup
  Name              = $stAccount
  SkuName           = 'Standard_RAGRS'
  Location          =  $location
}
$StorageAccount = New-AzStorageAccount @StorageHT
$Context = $StorageAccount.Context

New-AzStorageContainer -Name $containerName -Context $Context -Permission Blob

$Blob1HT = @{
  File             = 'C:/.../...'
  Container        = $containerName
  Blob             = "your file"
  Context          = $Context
  StandardBlobTier = 'Hot'
}
Set-AzStorageBlobContent @Blob1HT


#DATALAKE GEN2#

New-AzStorageAccount -ResourceGroupName $resourceGroup `
  -Name $dataLakeName `
  -Location $location `
  -SkuName Standard_RAGRS `
  -Kind StorageV2 `
  -EnableHierarchicalNamespace $True

 #CONTAINERS FOR DATALAKE

New-AzStorageContainer -Context $ctx -Name $datalakein
New-AzStorageContainer -Context $ctx -Name $datalakeout


#DATA_FACTORY & DATABRICKS#

$DataFactory = Set-AzDataFactoryV2 -ResourceGroupName $resourceGroup `
    -Location $location -Name $dataFactoryName

New-AzDatabricksWorkspace -Name "databricksbase1" -ResourceGroupName $resourceGroup -Location $location -ManagedResourceGroupName databricks-group -Sku standard

#SERVER & DATABASE#

# Create a new server with a system wide unique server name
$server = New-AzSqlServer -ResourceGroupName $resourceGroup `
    -ServerName $serverName `
    -Location $location `
    -SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $adminSqlLogin, $(ConvertTo-SecureString -String $password -AsPlainText -Force))

# Create a server firewall rule that allows access from the specified IP range
$serverFirewallRule = New-AzSqlServerFirewallRule -ResourceGroupName $resourceGroup `
    -ServerName $serverName `
    -FirewallRuleName "AllowedIPs" -StartIpAddress $startIp -EndIpAddress $endIp

New-AzSqlServerFirewallRule -ResourceGroupName $resourceGroup -ServerName $serverName -AllowAllAzureIPs

# Import bacpac to database with an S3 performance level
$importRequest = New-AzSqlDatabaseImport -ResourceGroupName $resourceGroup `
    -ServerName $serverName `
    -DatabaseName $databaseName `
    -DatabaseMaxSizeBytes 100GB `
    -StorageKeyType "StorageAccessKey" `
    -StorageKey $(Get-AzStorageAccountKey -ResourceGroupName $resourceGroup -StorageAccountName $stAccount).Value[0] `
    -StorageUri "https://$stAccount.blob.core.windows.net/$containerName/$bacpacFilename" `
    -Edition "Standard" `
    -ServiceObjectiveName "S3" `
    -AdministratorLogin "$adminSqlLogin" `
    -AdministratorLoginPassword $(ConvertTo-SecureString -String $password -AsPlainText -Force)