# *********************************************************
# mhosker GitHub
# *********************************************************

# ---------------------------------------------------------
# Backend
# ---------------------------------------------------------

terraform {
  backend "s3" {
    endpoints = {
      s3 = "https://lon1.digitaloceanspaces.com"
    }

    key = "github.tfstate"

    # Deactivate a few AWS-specific checks
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_s3_checksum            = true
    region                      = "eu-west-2"
  }
}

provider "github" {
  owner = "mhosker" # export GITHUB_OWNER=mhosker
  # app_auth {} # This broken see https://github.com/integrations/terraform-provider-github/issues/2241
}

# ---------------------------------------------------------
# Variables
# ---------------------------------------------------------

locals {
  team_admin = {
    "mhosker" = {
      role = "maintainer"
    }
  }
}

module "github" {
  source = "github.com/vincishq/terraform-module-github?ref=v1.0.0"

  # ---------------------------------------------------------
  # Defaults
  # ---------------------------------------------------------

  # Overriding the default to allow verified GitHub actions in repos
  default_actions_verified_allowed = true

  # Overriding the default allowed GitHub actions patterns as this is not supported with our free GitHub org on private repos
  default_actions_allowed_patterns = ["vincishq/*"]

  # ---------------------------------------------------------
  # Repositories
  # ---------------------------------------------------------

  repositories = {

    # ----------------------------------------
    # Core
    # ----------------------------------------

    "github" = {
      name            = "github"
      description     = "Terraform management of my GitHub config."
      visibility      = "public"
      allowed_actions = []
      protected_branches = {
        "main" = {
          pattern = "main"
          checks  = ["Terraform"]
        }
      }
    }

    # ----------------------------------------
    # Others
    # ----------------------------------------

    # "tfstate" = {
    #   name            = "tfstate"
    #   description     = "Terraform backend state locations."
    #   visibility      = "private"
    #   allowed_actions = []
    # }

    "dns" = {
      name            = "dns"
      description     = "DNS config management."
      visibility      = "private"
      allowed_actions = []
      # protected_branches = {
      #   "prod" = {
      #     pattern                    = "prod"
      #     checks                     = ["OctoDNS"]
      #     require_code_owner_reviews = true
      #   }
      # }
    }
  }

  # ---------------------------------------------------------
  # Teams
  # ---------------------------------------------------------

  teams = {
    # "admin" = {
    #   name        = "admin"
    #   description = ""
    #   permission  = "admin"
    #   members     = local.team_admin
    # }
    # "devops" = {
    #   name        = "devops"
    #   description = ""
    #   permission  = "push"
    #   members     = local.team_admin
    # }
  }
}
