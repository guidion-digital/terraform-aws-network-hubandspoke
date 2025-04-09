module "vpc_1" {
  source  = "aws-ia/vpc/aws"
  version = "4.4.4"

  name               = "vpc_1"
  cidr_block         = "192.168.1.0/24"
  az_count           = "3"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  transit_gateway_routes = {
    private = "0.0.0.0/0"
  }

  subnets = {
    private = {
      netmask = 26
    }
    transit_gateway = {
      netmask                                         = 28
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
      transit_gateway_appliance_mode_support          = "disable"
      transit_gateway_dns_support                     = "enable"
    }
  }
}

module "vpc_2" {
  source  = "aws-ia/vpc/aws"
  version = "4.4.4"

  name               = "vpc_2"
  cidr_block         = "192.168.2.0/24"
  az_count           = "3"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  transit_gateway_routes = {
    private = "0.0.0.0/0"
  }

  subnets = {
    private = {
      netmask = 26
    }
    transit_gateway = {
      netmask                                         = 28
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
      transit_gateway_appliance_mode_support          = "disable"
      transit_gateway_dns_support                     = "enable"
    }
  }
}

module "vpc_3" {
  source  = "aws-ia/vpc/aws"
  version = "4.4.4"

  name               = "vpc_3"
  cidr_block         = "192.168.3.0/24"
  az_count           = "3"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  transit_gateway_routes = {
    private = "0.0.0.0/0"
  }

  subnets = {
    private = {
      netmask = 26
    }
    transit_gateway = {
      netmask                                         = 28
      transit_gateway_default_route_table_association = false
      transit_gateway_default_route_table_propagation = false
      transit_gateway_appliance_mode_support          = "disable"
      transit_gateway_dns_support                     = "enable"
    }
  }
}


# module "vpc_4" {
#   source  = "aws-ia/vpc/aws"
#   version = "4.4.4"

#   name               = "vpc_4"
#   cidr_block         = "192.168.4.0/24"
#   az_count           = "3"
#   transit_gateway_id = aws_ec2_transit_gateway.tgw.id

#   transit_gateway_routes = {
#     private = "0.0.0.0/0"
#   }

#   subnets = {
#     private = {
#       netmask = 26
#     }
#     transit_gateway = {
#       netmask                                         = 28
#       transit_gateway_default_route_table_association = false
#       transit_gateway_default_route_table_propagation = false
#       transit_gateway_appliance_mode_support          = "disable"
#       transit_gateway_dns_support                     = "enable"
#     }
#   }
# }


# module "vpc_5" {
#   source  = "aws-ia/vpc/aws"
#   version = "4.4.4"

#   name               = "vpc_2"
#   cidr_block         = "192.168.5.0/24"
#   az_count           = "3"
#   transit_gateway_id = aws_ec2_transit_gateway.tgw.id

#   transit_gateway_routes = {
#     private = "0.0.0.0/0"
#   }

#   subnets = {
#     private = {
#       netmask = 26
#     }
#     transit_gateway = {
#       netmask                                         = 28
#       transit_gateway_default_route_table_association = false
#       transit_gateway_default_route_table_propagation = false
#       transit_gateway_appliance_mode_support          = "disable"
#       transit_gateway_dns_support                     = "enable"
#     }
#   }
# }
