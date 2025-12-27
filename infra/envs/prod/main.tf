module "resume_site" {
  source = "../../modules/resume_site"
  providers = {
    aws      = aws.use2
    aws.use1 = aws.use1
  }
}

module "counter_api" {
  source = "../../modules/counter_api"

  providers = {
    aws      = aws.use1
  }
}

module "blog_site" {
  source = "../../modules/blog_site"

  providers = {
    aws.use1 = aws.use1
    aws.use2 = aws.use2
    aws      = aws.use1
  }

  zone_name   = "harry-sivasambu.com."
  domain_name = "blog.harry-sivasambu.com"
  bucket_name = "hsivasambu-blog-prod"

  tags = {
    Project = "portfolio"
    Env     = "prod"
  }
}