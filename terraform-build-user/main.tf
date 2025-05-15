module "iam_user" {
  source = "github.com/cisagov/ami-build-iam-user-tf-module"

  providers = {
    aws            = aws
    aws.images-ami = aws.images-ami
    aws.images-ssm = aws.images-ssm
  }

  # This image can take a while to build, so we set the max session
  # duration to 4 hours.
  ec2amicreate_role_max_session_duration = 4 * 60 * 60
  ssm_parameters                         = ["/windows/commando/administrator/password"]
  user_name                              = "build-windows-commando-vm-packer"
}
