# Faker.Aws.En

Functions for generating AWS information in English

## ec2_action()

Returns an AWS EC2 Action

## Example

  iex> Faker.Aws.En.ec2_action()
  "CreateVpcEndpoint"
  iex> Faker.Aws.En.ec2_action()
  "RevokeSecurityGroupEgress"
  iex> Faker.Aws.En.ec2_action()
  "GetTransitGatewayRouteTableAssociations"
  iex> Faker.Aws.En.ec2_action()
  "RunScheduledInstances"

## rds_action()

Returns an AWS RDS Action

## Example

  iex> Faker.Aws.En.rds_action()
  "DeleteDBClusterEndpoint"
  iex> Faker.Aws.En.rds_action()
  "CopyDBSnapshot"
  iex> Faker.Aws.En.rds_action()
  "ModifyDBParameterGroup"
  iex> Faker.Aws.En.rds_action()
  "DescribeDBClusterSnapshots"

## region_code()

Returns a random region code available on AWS

## Examples

    iex> Faker.Aws.En.region_code()
    "ap-northeast-1"
    iex> Faker.Aws.En.region_code()
    "us-east-2"
    iex> Faker.Aws.En.region_code()
    "eu-south-1"
    iex> Faker.Aws.En.region_code()
    "af-south-1"

## region_name()

Returns a random region name available on AWS

## Examples

    iex> Faker.Aws.En.region_name()
    "Asia Pacific (Tokyo)"
    iex> Faker.Aws.En.region_name()
    "US East (Ohio)"
    iex> Faker.Aws.En.region_name()
    "Europe (Milan)"
    iex> Faker.Aws.En.region_name()
    "Africa (Cape Town)"

## s3_action()

Returns an AWS S3 Action

## Example

  iex> Faker.Aws.En.s3_action()
  "DeleteBucketTagging"
  iex> Faker.Aws.En.s3_action()
  "DeleteObjects"
  iex> Faker.Aws.En.s3_action()
  "PutPublicAccessBlock"
  iex> Faker.Aws.En.s3_action()
  "PutBucketReplication"

## service()

Returns a random AWS service

## Examples

  iex> Faker.Aws.En.service()
  "AWS Compute Optimizer"
  iex> Faker.Aws.En.service()
  "Ground Station"
  iex> Faker.Aws.En.service()
  "Neptune"
  iex> Faker.Aws.En.service()
  "DataSync"