variable "private_key" {
  description = "Path to the SSH private key file"
  type        = string
  default     = "/home/ubuntu/.ssh/authorized_keys/jenkins_key" 
}
