# Le sous-réseau public
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  
  tags                    = { Name = "Public Subnet A" }
}

# Le sous-réseau privé

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1a"
  
  tags                    = { Name = "Private Subnet A" }
}

# Sous-réseau public - AZ b
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b" 

  tags = { Name = "Public Subnet B" }
}

# Sous-réseau privé - AZ b
resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"       

  tags = { Name = "Private Subnet B" }
}

# Internet Gateway pour le sous-réseau public
resource "aws_internet_gateway" "igw" {
  vpc_id                  = aws_vpc.main.id
}