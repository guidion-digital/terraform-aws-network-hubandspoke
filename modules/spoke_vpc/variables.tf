# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

# --- modules/spoke_vpc/variables.tf ---

# Identifier
variable "identifier" {
  type        = string
  description = "Module identifier."
}

# VPC Parameters
variable "vpc_name" {
  type        = string
  description = "Spoke VPC name."
}

variable "cidr_block" {
  type        = string
  description = "Spoke VPC CIDR block."
}

variable "number_azs" {
  type        = number
  description = "Number of AZs to use in the VPC."
}

variable "azs_available" {
  type        = list(string)
  description = "List of AZs available in the AWS Region."
}

variable "enable_logging" {
  type        = bool
  description = "Boolean indicating if logging should be added in the VPC."
}

variable "kms_key" {
  type        = string
  description = "KMS Key to encrypt logs (if enabled)"
}

variable "endpoints_vpc_created" {
  type        = bool
  description = "Indicates if VPC endpoints are centralized or not."
}

# Transit Gateway ID - to create TGW Attachment and routes
variable "tgw_id" {
  type        = string
  description = "Transit Gateway ID - to create TGW Attachment and routes"
}

# VPC Flow Logs IAM Role - if applicable
variable "vpc_flowlog_role" {
  type        = string
  description = "ARN of the IAM role to use for VPC flow logs - if applicable."
}