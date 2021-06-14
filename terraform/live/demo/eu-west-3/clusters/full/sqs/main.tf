module "sqs" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "~> 2.0"

  name = "sqs-keda-${local.env}"

  tags = local.custom_tags
}

module "scaler_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "~> 3.0"

  name          = "keda-sqs"
  force_destroy = true

  create_iam_user_login_profile = false
  password_reset_required       = false
}

data "aws_iam_policy_document" "sqs" {
  statement {
    actions = [
      "sqs:*"
    ]
    resources = [
      "arn:aws:sqs:*:*:*"
    ]
  }
}

resource "aws_iam_policy" "sqs-admin" {
  name        = "sqs-admin"
  description = "Allow every action on SQS resources"
  policy      = data.aws_iam_policy_document.sqs.json
}

resource "aws_iam_user_policy_attachment" "keda-admin" {
  user       = module.scaler_user.this_iam_user_name
  policy_arn = aws_iam_policy.sqs-admin.arn

  depends_on = [
    module.scaler_user
  ]
}

output "sqs" {
  value = module.sqs
}

output "iam" {
  value     = module.scaler_user
  sensitive = true
}
