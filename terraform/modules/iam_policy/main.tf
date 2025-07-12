resource "aws_iam_policy" "rds_policy" {
  name        = var.policy_name
  path        = "/"
  description = "Policy for RDS access and management"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds:CreateDBInstance",
          "rds:DeleteDBInstance",
          "rds:DescribeDBInstances",
          "rds:ListTagsForResource",
          "rds:AddTagsToResource",
          "rds:DescribeDBSnapshots",
          "rds:CreateDBSubnetGroup",
          "rds:DeleteDBSubnetGroup",
          "rds:DescribeDBSubnetGroups"
        ]
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_user_policy_attachment" "policy_attach" {
  user       = var.user
  policy_arn = aws_iam_policy.rds_policy.arn
}
