## Azure Virtual Network

Azure Virtual Network (VNet) is a fundamental building block in your private network within Azure. VNet enables various Azure services and VMs to securely communicate with each other, the internet, and on-premises networks. A VNet is similar to a traditional network that you’d operate in your own data center but brings along additional benefits of Azure's infrastructure like scalability, availability, and isolation.

### Design Decisions

- **Resource Group Management**: Each Virtual Network is contained in a distinct resource group. This allows for better organization and easier management of the VNet resources.
- **Address Space Allocation**: The module either automatically picks an available CIDR block from predefined ranges or uses a user-defined CIDR.
- **Default Subnet**: A default subnet is created within the VNet to ensure there is at least one subnet available immediately.
- **Service Endpoints**: The default subnet includes an endpoint for Microsoft.Storage to facilitate direct and secure connectivity to Azure Storage services.
- **Monitoring and Alarms**: The module includes optional DDoS attack metric alerts, automatically setup depending on the monitoring configuration. The alerts are linked to an alarm channel for centralized management.

### Runbook

#### Connectivity Issues Within VNet

If you are experiencing connectivity issues between resources within the Virtual Network, you can use the Azure CLI to diagnose and troubleshoot the problem.

1. **Check VNet and Subnet Configuration**:

```sh
# List VNets in the resource group
az network vnet list --resource-group [RESOURCE_GROUP_NAME]

# Show details of a specific VNet
az network vnet show --resource-group [RESOURCE_GROUP_NAME] --name [VNET_NAME]

# List Subnets in the VNet
az network vnet subnet list --resource-group [RESOURCE_GROUP_NAME] --vnet-name [VNET_NAME]
```

Expect to see VNet and subnet configurations that match your deployed infrastructure requirements. Verify if the address spaces and subnet configurations are correct.

2. **Verify Effective Security Rules**:

```sh
# Get the effective security rules for a network interface
az network nic list-effective-nsg --resource-group [RESOURCE_GROUP_NAME] --name [NIC_NAME]
```

This command lists all effective network security rules applied to the NIC. Verify if there are any blocking rules preventing connectivity.

#### Diagnosing DDoS Attacks

If you suspect the VNet is under a DDoS attack, you can use the Azure Monitor metrics and configured alerts.

1. **View Metrics of DDoS Attack**:

```sh
# Get metrics for DDoS attack
az monitor metrics list --resource [VNET_ID] --metric IfUnderDDoSAttack --interval PT1M
```

Inspect the metrics to understand if there are any ongoing DDoS attacks.

2. **Check Configured Alerts**:

```sh
# List alerts
az monitor alert list --resource-group [RESOURCE_GROUP_NAME]
```

Ensure that DDoS alert configurations are in place and examine alert history to understand recent triggers.

3. **Monitoring Logs**:

```sh
# View activity logs
az monitor activity-log list --resource-group [RESOURCE_GROUP_NAME]
```

Use logs to pinpoint the time and nature of the incidents affecting the virtual network.

#### Subnet Configuration Issues

If a resource cannot connect to Azure Storage services via the service endpoint configured on a subnet, use the following commands to troubleshoot.

1. **Check Service Endpoints on Subnets**:

```sh
# Show details of a subnet
az network vnet subnet show --resource-group [RESOURCE_GROUP_NAME] --vnet-name [VNET_NAME] --name [SUBNET_NAME]
```

Look for the `serviceEndpoints` field to confirm that the Microsoft.Storage endpoint is configured.

By following these troubleshooting procedures, you should be able to diagnose common issues with Azure Virtual Network effectively.

