provider "github" {
  token        = var.github_token
  organization = "Practical-DevOps-GitHub/github-terraform-task"  # Replace with your GitHub organization name
}

resource "github_repository" "repo" {
  name             = "your-repo-name"  # Replace with your desired repository name
  description      = "SoftServe"  # Replace with your repository description
  private          = true
  visibility       = "private"
  has_issues       = true
  has_projects     = true
  has_wiki         = false
  default_branch   = "develop"
}

resource "github_repository_collaborator" "collaborator" {
  repository = github_repository.repo.name
  username   = "softservedata"
  permission = "push"
}

resource "github_branch" "main" {
  repository = github_repository.repo.name
  branch     = "main"
}

resource "github_branch" "develop" {
  repository = github_repository.repo.name
  branch     = "develop"
}

resource "github_branch_protection" "main" {
  repository = github_repository.repo.name
  branch     = github_branch.main.branch

  required_pull_request_reviews {
    dismiss_stale_reviews  = true
    dismissal_users        = []
    dismissal_teams        = []
    require_code_owner_reviews = true
    required_approving_review_count = 1
  }

  required_status_checks {
    strict   = true
    contexts = []
  }
}

resource "github_branch_protection" "develop" {
  repository = github_repository.repo.name
  branch     = github_branch.develop.branch

  required_pull_request_reviews {
    dismiss_stale_reviews  = true
    dismissal_users        = []
    dismissal_teams        = []
    require_code_owner_reviews = false
    required_approving_review_count = 2
  }

  required_status_checks {
    strict   = true
    contexts = []
  }
}

resource "github_repository_file" "pull_request_template" {
  repository = github_repository.repo.name
  file_path  = ".github/pull_request_template.md"
  content    = file("${path.module}/pull_request_template.md")
  message    = "Add pull request template"
}

resource "github_repository_deploy_key" "deploy_key" {
  repository = github_repository.repo.name
  title      = "DEPLOY_KEY"
  key        = "your-public-ssh-key"  # Replace with your public SSH key
  read_only  = false
}

resource "github_repository_webhook" "discord_webhook" {
  repository = github_repository.repo.name
  name       = "discord"
  events     = ["pull_request"]
  configuration {
    url          = "https://your-discord-webhook-url"  # Replace with your Discord webhook URL
    content_type = "json"
  }
}
