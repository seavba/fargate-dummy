resource "aws_ecr_repository" "ecr_repo" {
  name                 = "${var.ecr_repo}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "null_resource" "docker" {
   provisioner "local-exec" {
   command = <<-EOT
     docker build -t "${local.ecr_repo_url}/${var.ecr_repo}:${var.ecr_image_tag}" ..
     aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${local.ecr_repo_url}
     docker push "${local.ecr_repo_url}/${var.ecr_repo}:${var.ecr_image_tag}"
   EOT
   }
 }
