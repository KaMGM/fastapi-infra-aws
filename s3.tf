# Bucket Public (Site HTML)
resource "aws_s3_bucket" "public_site" {
  bucket = "my-static-site-public-${var.env}"

  tags = {
    Name = "Bucket Public HTML"
  }
}

# Politique publique pour le bucket
resource "aws_s3_bucket_public_access_block" "public_block" {
  bucket = aws_s3_bucket.public_site.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket Privé (Dossiers d'achat/location)
resource "aws_s3_bucket" "private_docs" {
  bucket = "my-private-docs-${var.env}"

  tags = {
    Name = "Bucket Privé Documents"
  }
}

resource "aws_s3_bucket_public_access_block" "private_block" {
  bucket = aws_s3_bucket.private_docs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}