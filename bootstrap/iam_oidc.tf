# OIDC do GitHub + role para a pipeline assumir via STS (sem chaves)
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  # Thumbprint do certificado raiz do GitHub OIDC (validar periodicamente)
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

data "aws_iam_policy_document" "gha_assume" {
  statement {
    effect   = "Allow"
    actions  = ["sts:AssumeRoleWithWebIdentity"]
    principals { type = "Federated" identifiers = [aws_iam_openid_connect_provider.github.arn] }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.gh_owner}/${var.gh_repo}:*"]
    }
  }
}

resource "aws_iam_role" "gha" {
  name               = "gha-oidc-terraform"
  assume_role_policy = data.aws_iam_policy_document.gha_assume.json
}

# Para POC usamos AdministratorAccess; em producao substitua por politicas especificas
resource "aws_iam_role_policy_attachment" "admin_temp" {
  role       = aws_iam_role.gha.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "gha_role_arn" { value = aws_iam_role.gha.arn }
