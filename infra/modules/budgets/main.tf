variable "amount" { type = number }
variable "email"  { type = string }

resource "aws_budgets_budget" "monthly" {
  name              = "MonthlyBudget"
  budget_type       = "COST"
  limit_amount      = tostring(var.amount)
  limit_unit        = "USD"
  time_unit         = "MONTHLY"

  notification {
    comparison_operator = "GREATER_THAN"
    threshold           = 80
    threshold_type      = "PERCENTAGE"
    notification_type   = "ACTUAL"
    subscriber_email_addresses = [var.email]
  }
}