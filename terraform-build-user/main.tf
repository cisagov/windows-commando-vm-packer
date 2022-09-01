module "iam_user" {
  source = "github.com/cisagov/ami-build-iam-user-tf-module"

  providers = {
    aws                       = aws
    aws.images-production-ami = aws.images-production-ami
    aws.images-staging-ami    = aws.images-staging-ami
    aws.images-production-ssm = aws.images-production-ssm
    aws.images-staging-ssm    = aws.images-staging-ssm
  }

  # This image can take a while to build, so we set the max session
  # duration to 3 hours.
  ec2amicreate_role_max_session_duration = 3 * 60 * 60
  ssm_parameters                         = ["/windows/commando/administrator/password"]
  user_name                              = "build-windows-commando-vm-packer"
}
