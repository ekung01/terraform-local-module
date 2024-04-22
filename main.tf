# create ec2 instances

module "EC2" {
    source = "./EC2"
    subnet_id = module.VPC.public_subnet1_id
    security_group_ids = [module.VPC.security_group_id]

    depends_on = [
        module.VPC
    ]
}

# create vpc
module "VPC" {
    source = "./VPC"
}

