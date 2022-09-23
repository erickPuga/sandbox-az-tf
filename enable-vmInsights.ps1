# Commands used
#az monitor log-analytics workspace get-shared-keys --resource-group $ResourceGroup --workspace-name $WorkspaceName
#Get-AzOperationalInsightsWorkspaceSharedKey -ResourceGroupName $ResourceGroup -Name $WorkspaceName


$WorkspaceId = "c37e78a5-2fd6-4a0e-8e7e-2b46b3946281"
$SubscriptionId = "8911ade0-2192-425e-a08d-c27be185a83e"
$ResourceGroup = "rg-test-insights"
$WorkspaceName = "wks-insights-test01"
$WorkspaceKey = Get-AzOperationalInsightsWorkspaceSharedKey -ResourceGroupName $ResourceGroup -Name $WorkspaceName


.\Install-VMInsights.ps1 -WorkspaceId $WorkspaceId -WorkspaceKey $WorkspaceKey.PrimarySharedKey -SubscriptionId $SubscriptionId -WorkspaceRegion eastus2 -ResourceGroup $ResourceGroup