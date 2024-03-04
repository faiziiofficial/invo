# Create an S3 bucket for content delivery network (CDN)
resource "aws_s3_bucket" "cdn_bucket" {
  bucket = "mybucket27feb"

  tags = {
    Name = "My bucket"
  }
}

# Create a CloudFront distribution for content delivery
resource "aws_cloudfront_distribution" "my_distribution" {
  origin {
    # Specify the S3 bucket domain name as the origin
    domain_name = "mybucket27feb.s3.amazonaws.com"
    origin_id   = "CustomOrigin"
  }

  # Enable the CloudFront distribution
  enabled             = true
  
  # Enable IPv6 support
  is_ipv6_enabled     = true
  
  # Provide a comment for the CloudFront distribution
  comment             = "My CloudFront Distribution"
  
  # Define default cache behavior
  default_cache_behavior {
    target_origin_id       = "CustomOrigin"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    
    # Specify the viewer protocol policy
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Add additional cache behaviors or customizations as needed

  # Define viewer certificate settings
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # Restrict access to the CloudFront distribution
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }
}
