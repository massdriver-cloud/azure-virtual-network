resource "azurerm_monitor_action_group" "main" {
  name                = "${var.md_metadata.name_prefix}-alarms"
  short_name          = "Massdriver Alarms"
  resource_group_name = azurerm_resource_group.main.name

  webhook_receiver {
    name                    = "Massdriver Observability Webhook API"
    service_uri             = var.md_metadata.observability.alarm_webhook_url
    use_common_alert_schema = true
  }
}
