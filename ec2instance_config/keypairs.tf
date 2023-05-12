resource "aws_key_pair" "bastion_keypair" {
  key_name   = var.key_pair_name
  public_key = var.key_pair_public_key
  tags       = var.default_tags
}
