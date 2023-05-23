locals {
  automated_alarms = {
    ddos_attack_metric_alert = {
      severity    = "0"
      frequency   = "PT1M"
      window_size = "PT5M"
      operator    = "GreaterThanOrEqual"
      aggregation = "Maximum"
      threshold   = 1
    }
  }
  alarms_map = {
    "AUTOMATED" = local.automated_alarms
    "DISABLED"  = {}
    "CUSTOM"    = lookup(var.monitoring, "alarms", {})
  }
  alarms             = lookup(local.alarms_map, var.monitoring.mode, {})
  monitoring_enabled = var.monitoring.mode != "DISABLED" ? 1 : 0
}

module "alarm_channel" {
  source              = "github.com/massdriver-cloud/terraform-modules//azure/alarm-channel?ref=e9fbd67"
  md_metadata         = var.md_metadata
  resource_group_name = azurerm_resource_group.main.name
}

module "ddos_attack_metric_alert" {
  count                   = local.monitoring_enabled
  source                  = "github.com/massdriver-cloud/terraform-modules//azure/monitor-metrics-alarm?ref=e9fbd67"
  scopes                  = [azurerm_virtual_network.main.id]
  resource_group_name     = azurerm_resource_group.main.name
  monitor_action_group_id = module.alarm_channel.id
  severity                = local.alarms.ddos_attack_metric_alert.severity
  frequency               = local.alarms.ddos_attack_metric_alert.frequency
  window_size             = local.alarms.ddos_attack_metric_alert.window_size

  depends_on = [
    azurerm_virtual_network.main
  ]

  md_metadata  = var.md_metadata
  display_name = "DDoS Attack"
  message      = "VNet Under DDoS Attack"

  alarm_name       = "${var.md_metadata.name_prefix}-underDDoSAttack"
  operator         = local.alarms.ddos_attack_metric_alert.operator
  metric_name      = "IfUnderDDoSAttack"
  metric_namespace = "microsoft.network/virtualnetworks"
  aggregation      = local.alarms.ddos_attack_metric_alert.aggregation
  threshold        = local.alarms.ddos_attack_metric_alert.threshold
}
