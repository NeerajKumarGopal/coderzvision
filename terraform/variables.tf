variable "private_key" {
  description = "Path to the SSH private key file"
  type        = string
  default     = "~/.ssh/authorized_keys/jenkins_key" 
}
