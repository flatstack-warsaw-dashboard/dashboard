resource "aws_codestarconnections_connection" "gh_connection" {
  name          = "gh-connection"
  provider_type = "GitHub"
}
