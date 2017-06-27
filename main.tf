# Example to spin up a multi node redshift cluster
provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

# VPC for redshift
resource "aws_vpc" "vpc_redshift" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  tags {
    application   = "${var.tag_application}"
    team          = "${var.tag_team}"
    environment   = "${var.tag_environment}"
    contact-email = "${var.tag_contact_email}"
  }
}

# Internet gateway for VPC
resource "aws_internet_gateway" "igw_redshift" {
  depends_on = ["aws_vpc.vpc_redshift"]
  vpc_id     = "${aws_vpc.vpc_redshift.id}"

  tags {
    application   = "${var.tag_application}"
    team          = "${var.tag_team}"
    environment   = "${var.tag_environment}"
    contact-email = "${var.tag_contact_email}"
  }
}

# VPC Subnet for us west2 a
resource "aws_subnet" "sn_redshift_uswest2a" {
  depends_on        = ["aws_vpc.vpc_redshift"]
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-west-2a"
  vpc_id            = "${aws_vpc.vpc_redshift.id}"

  tags {
    application   = "${var.tag_application}"
    team          = "${var.tag_team}"
    environment   = "${var.tag_environment}"
    contact-email = "${var.tag_contact_email}"
  }
}

# VPC Subnet for us west2 b
resource "aws_subnet" "sn_redshift_uswest2b" {
  depends_on        = ["aws_vpc.vpc_redshift"]
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2b"
  vpc_id            = "${aws_vpc.vpc_redshift.id}"

  tags {
    application   = "${var.tag_application}"
    team          = "${var.tag_team}"
    environment   = "${var.tag_environment}"
    contact-email = "${var.tag_contact_email}"
  }
}

# VPC Subnet for us west2 c
resource "aws_subnet" "sn_redshift_uswest2c" {
  depends_on        = ["aws_vpc.vpc_redshift"]
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2c"
  vpc_id            = "${aws_vpc.vpc_redshift.id}"

  tags {
    application   = "${var.tag_application}"
    team          = "${var.tag_team}"
    environment   = "${var.tag_environment}"
    contact-email = "${var.tag_contact_email}"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.vpc_redshift.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.igw_redshift.id}"
}

resource "aws_route_table_association" "public_subnet_us_west_2a_association" {
  subnet_id      = "${aws_subnet.sn_redshift_uswest2a.id}"
  route_table_id = "${aws_vpc.vpc_redshift.main_route_table_id}"
}

# Redshift subnet group with all 5 subnets above
resource "aws_redshift_subnet_group" "redshift_sn" {
  depends_on  = ["aws_vpc.vpc_redshift", "aws_internet_gateway.igw_redshift", "aws_subnet.sn_redshift_uswest2a", "aws_subnet.sn_redshift_uswest2b", "aws_subnet.sn_redshift_uswest2c"]
  name        = "subnet-group-${var.tag_name}"
  description = "subnet-group-${var.tag_team}-${var.tag_application}-${var.tag_environment}"
  subnet_ids  = ["${aws_subnet.sn_redshift_uswest2a.id}", "${aws_subnet.sn_redshift_uswest2b.id}", "${aws_subnet.sn_redshift_uswest2c.id}"]  

  tags {
    application   = "${var.tag_application}"
    team          = "${var.tag_team}"
    environment   = "${var.tag_environment}"
    contact-email = "${var.tag_contact_email}"
  }
}

# Elastic IP
resource "aws_eip" "redshift" {
  depends_on                = ["aws_vpc.vpc_redshift", "aws_internet_gateway.igw_redshift", "aws_subnet.sn_redshift_uswest2a", "aws_subnet.sn_redshift_uswest2b", "aws_subnet.sn_redshift_uswest2c"]  
  vpc                       = true
  associate_with_private_ip = "10.0.0.214"
}

# Security group for redshift
resource "aws_security_group" "sg_redshift" {
  depends_on = ["aws_vpc.vpc_redshift", "aws_internet_gateway.igw_redshift"]
  vpc_id     = "${aws_vpc.vpc_redshift.id}"

  ingress {
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    application   = "${var.tag_application}"
    team          = "${var.tag_team}"
    environment   = "${var.tag_environment}"
    contact-email = "${var.tag_contact_email}"
  }
}

# Redshift paramteer group
resource "aws_redshift_parameter_group" "rs_parameter_group" {
  name   = "parameter-group-${var.tag_name}"
  family = "redshift-1.0"

  parameter {
    name  = "datestyle"
    value = "ISO, MDY"
  }

  parameter {
    name  = "enable_user_activity_logging"
    value = "false"
  }

  parameter {
    name  = "extra_float_digits"
    value = "0"
  }

  parameter {
    name  = "max_cursor_result_set_size"
    value = "0"
  }

  parameter {
    name  = "query_group"
    value = "default"
  }

  parameter {
    name  = "require_ssl"
    value = "false"
  }

  parameter {
    name  = "search_path"
    value = "$user, public"
  }

  parameter {
    name  = "statement_timeout"
    value = "0"
  }
}

# Redshift setup
resource "aws_redshift_cluster" "default" {
  depends_on                   = ["aws_vpc.vpc_redshift", "aws_internet_gateway.igw_redshift", "aws_eip.redshift", "aws_redshift_subnet_group.redshift_sn", "aws_security_group.sg_redshift", "aws_redshift_parameter_group.rs_parameter_group"]
  cluster_identifier           = "${var.cluster_id}"
  database_name                = "${var.db_name}"
  master_username              = "${var.master_username}"
  master_password              = "${var.master_password}"
  node_type                    = "${var.node_type}"
  cluster_type                 = "${var.cluster_type}"
  cluster_parameter_group_name = "${aws_redshift_parameter_group.rs_parameter_group.name}"
  vpc_security_group_ids       = ["${aws_security_group.sg_redshift.id}"]
  cluster_subnet_group_name    = "${aws_redshift_subnet_group.redshift_sn.id}"
  availability_zone            = "${var.availability_zone}"
  elastic_ip                   = "${aws_eip.redshift.public_ip}"
  encrypted                    = "${var.encrypted}"
  number_of_nodes              = "${var.number_of_nodes}"
  skip_final_snapshot          = "${var.skip_final_snapshot}"

  tags {
    application   = "${var.tag_application}"
    team          = "${var.tag_team}"
    environment   = "${var.tag_environment}"
    contact-email = "${var.tag_contact_email}"
  }
}
