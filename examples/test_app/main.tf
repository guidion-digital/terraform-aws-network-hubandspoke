locals {
  vpc_information = {
    # vpc-do-nothing = {
    #   vpc_id                        = ""
    #   vpc_cidr                      = null
    #   transit_gateway_attachment_id = null
    #   routing_domain                = "do-nothing"
    #   office_reachable              = false
    #   aws_client_vpn_reachable      = false
    # },
    vpc-1 = {
      vpc_id                        = ""
      vpc_cidr                      = module.vpc_1.vpc_attributes.cidr_block
      transit_gateway_attachment_id = module.vpc_1.transit_gateway_attachment_id
      routing_domain                = "vpc-1"
      office_reachable              = false
      aws_client_vpn_reachable      = false
    },
    # vpc-2 = {
    #   vpc_id                        = ""
    #   vpc_cidr                      = module.vpc_2.vpc_attributes.cidr_block
    #   transit_gateway_attachment_id = module.vpc_2.transit_gateway_attachment_id
    #   routing_domain                = "vpc-2"
    #   office_reachable              = false
    #   aws_client_vpn_reachable      = false
    # },
    vpc-3 = {
      vpc_id                        = ""
      vpc_cidr                      = module.vpc_3.vpc_attributes.cidr_block
      transit_gateway_attachment_id = module.vpc_3.transit_gateway_attachment_id
      routing_domain                = "vpc-3"
      office_reachable              = false
      aws_client_vpn_reachable      = false
    },
    # vpc-4 = {
    #   vpc_id                        = ""
    #   vpc_cidr                      = module.vpc_4.vpc_attributes.cidr_block
    #   transit_gateway_attachment_id = module.vpc_4.transit_gateway_attachment_id
    #   routing_domain                = "vpc-4"
    #   office_reachable              = false
    #   aws_client_vpn_reachable      = false
    # },
    # vpc-5 = {
    #   vpc_id                        = ""
    #   vpc_cidr                      = module.vpc_5.vpc_attributes.cidr_block
    #   transit_gateway_attachment_id = module.vpc_5.transit_gateway_attachment_id
    #   routing_domain                = "vpc-5"
    #   office_reachable              = false
    #   aws_client_vpn_reachable      = false
    # }
  }
  # Create a new map with only the entries that have a non-empty transit_gateway_attachment_id.
  enabled_vpc_information = {
    for name, info in local.vpc_information : name => info
    if info.transit_gateway_attachment_id != null
  }

  number_vpcs = length(local.enabled_vpc_information)
}


resource "aws_ec2_transit_gateway" "tgw" {

  description                     = "test-tgw"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  auto_accept_shared_attachments  = "enable"
  amazon_side_asn                 = 64515

  tags = {
    Name = "test-tgw"
  }
}

module "hub-and-spoke" {
  source = "../../"

  identifier         = "guidion"
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id

  network_definition = {
    type  = "PREFIX_LIST"
    value = aws_ec2_managed_prefix_list.network_prefix_list.id
  }

  spoke_vpcs = {
    routing_domains = keys(local.enabled_vpc_information)
    number_vpcs     = local.number_vpcs

    vpc_information = {
      for name, info in local.enabled_vpc_information :
      name => {
        vpc_id                        = info.vpc_id
        transit_gateway_attachment_id = info.transit_gateway_attachment_id
        routing_domain                = info.routing_domain
      }
    }
  }

  central_vpcs = {
    egress = {
      name       = "egress-vpc"
      cidr_block = "10.120.1.0/24"
      az_count   = 3

      subnets = {
        public          = { netmask = 26 }
        transit_gateway = { netmask = 28 }
      }
    }

    ingress = {
      name       = "ingress-vpc"
      cidr_block = "10.120.0.0/24"
      az_count   = 3

      subnets = {
        public          = { netmask = 26 }
        transit_gateway = { netmask = 28 }
      }
    }

    # shared_services = {
    #   name       = "shared-services-vpc"
    #   cidr_block = "10.120.2.0/24"
    #   az_count   = 3

    #   subnets = {
    #     endpoints       = { netmask = 26 }
    #     transit_gateway = { netmask = 28 }
    #   }
    # }
  }
}

resource "aws_ec2_managed_prefix_list" "network_prefix_list" {
  name           = "Subnets for TGW routing"
  address_family = "IPv4"
  max_entries    = 25

  dynamic "entry" {
    for_each = local.enabled_vpc_information

    content {
      cidr        = entry.value["vpc_cidr"]
      description = entry.value["routing_domain"]
    }
  }
  entry {
    cidr        = "192.168.178.0/24"
    description = "office-server"
  }
  entry {
    cidr        = "192.168.174.0/23"
    description = "office_site_to_site_vpn"
  }
}

# Managed prefix list for sharing with Office Router through BGP.
# resource "aws_ec2_managed_prefix_list" "network_prefix_list_site_to_site_vpn" {
#   name           = "Network's Prefix List"
#   address_family = "IPv4"
#   max_entries    = 25

#   dynamic "entry" {
#     for_each = {
#       for name, info in local.enabled_vpc_information :
#       name => info if info.office_reachable
#     }
#     content {
#       cidr        = entry.value.vpc_cidr
#       description = entry.value.routing_domain
#     }
#   }
# }

# add routes to egress tgw route tables to prevent NATing for these subnets
# FIXME: This resource can not be created until the others have been
# resource "aws_route" "egress_tgw_to_tgw_prevent_nat" {
#   for_each = toset(values(module.hub-and-spoke.central_vpcs.egress.rt_attributes_by_type_by_az.transit_gateway)[*].id)
#
#   destination_prefix_list_id = aws_ec2_managed_prefix_list.network_prefix_list.id
#
#   route_table_id     = each.value
#   transit_gateway_id = aws_ec2_transit_gateway.tgw.id
# }


# resource "aws_ec2_transit_gateway_route_table" "office_site_to_site_vpn" {
#   transit_gateway_id = aws_ec2_transit_gateway.tgw.id
#   tags = {
#     Name = "vpn-tgw-rt-guidion"
#   }
# }

# resource "aws_ec2_transit_gateway_route_table_association" "vpn_gateway_eurofiber_ne338789" {
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.office_site_to_site_vpn.id
#   transit_gateway_attachment_id  = module.vpn_gateway_eurofiber_ne338789.vpn_connection_transit_gateway_attachment_id
# }
#
# resource "aws_ec2_transit_gateway_route_table_association" "vpn_gateway_eurofiber_ne338790" {
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.office_site_to_site_vpn.id
#   transit_gateway_attachment_id  = module.vpn_gateway_eurofiber_ne338790.vpn_connection_transit_gateway_attachment_id
# }
#
# resource "aws_ec2_transit_gateway_route_table_propagation" "vpn_gateway_eurofiber_ne338789" {
#   transit_gateway_attachment_id  = module.vpn_gateway_eurofiber_ne338789.vpn_connection_transit_gateway_attachment_id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.office_site_to_site_vpn.id
# }
#
# resource "aws_ec2_transit_gateway_route_table_propagation" "vpn_gateway_eurofiber_ne338790" {
#   transit_gateway_attachment_id  = module.vpn_gateway_eurofiber_ne338790.vpn_connection_transit_gateway_attachment_id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.office_site_to_site_vpn.id
# }
#
# resource "aws_ec2_transit_gateway_route_table_propagation" "egress_tgw_rtb_office__routes_vpn_ne338789" {
#   transit_gateway_attachment_id  = module.vpn_gateway_eurofiber_ne338789.vpn_connection_transit_gateway_attachment_id
#   transit_gateway_route_table_id = module.hub-and-spoke.transit_gateway_route_tables.central_vpcs.egress.id
# }
#
# resource "aws_ec2_transit_gateway_route_table_propagation" "egress_tgw_rtb_office__routes_vpn_ne338790" {
#   transit_gateway_attachment_id  = module.vpn_gateway_eurofiber_ne338790.vpn_connection_transit_gateway_attachment_id
#   transit_gateway_route_table_id = module.hub-and-spoke.transit_gateway_route_tables.central_vpcs.egress.id
# }
#
# resource "aws_ec2_transit_gateway_prefix_list_reference" "office_site_to_site_vpn_routes" {
#   prefix_list_id                 = aws_ec2_managed_prefix_list.network_prefix_list_site_to_site_vpn.id
#   transit_gateway_attachment_id  = "tgw-attach-06997c0238aae5c50"
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.office_site_to_site_vpn.id
# }
#
# resource "aws_ec2_transit_gateway_route" "office_site_to_site_vpn_ingress_routes" {
#   destination_cidr_block         = module.hub-and-spoke.central_vpcs.ingress.vpc_attributes.cidr_block
#   transit_gateway_attachment_id  = module.hub-and-spoke.central_vpcs.ingress.transit_gateway_attachment_id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.office_site_to_site_vpn.id
# }
#
# resource "aws_ec2_transit_gateway_route" "office_site_to_site_vpn_egress_routes" {
#   destination_cidr_block         = module.hub-and-spoke.central_vpcs.egress.vpc_attributes.cidr_block
#   transit_gateway_attachment_id  = module.hub-and-spoke.central_vpcs.ingress.transit_gateway_attachment_id
#   transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.office_site_to_site_vpn.id
# }
