resource "google_cloud_scheduler_job" "job" {
  project          = var.project_id
  region           = var.location
  name             = var.workflow_scheduler_name
  description      = "Scheduler for team league workflow"
  schedule         = var.workflow_scheduler_interval
  time_zone        = var.workflow_scheduler_timezone
  attempt_deadline = "320s"

  http_target {
    body = base64encode(
      jsonencode({
        "argument" : local.team_league_workflow_yaml_config_as_string,
        "callLogLevel" : "CALL_LOG_LEVEL_UNSPECIFIED"
      }
      ))
    http_method = "POST"
    uri         = "https://workflowexecutions.googleapis.com/v1/projects/${var.project_id}/locations/${var.location}/workflows/${var.workflow_name}/executions"

    oauth_token {
      scope                 = "https://www.googleapis.com/auth/cloud-platform"
      service_account_email = var.workflow_scheduler_sa
    }
  }
}

resource "google_workflows_workflow" "workflow_etl_team_league_dataflow" {
  project         = var.project_id
  region          = var.location
  name            = var.workflow_name
  description     = "Workflow for team league ETL"
  service_account = var.workflow_sa
  source_contents = local.team_league_workflow_yaml_as_string
}
