output "vpc_id" {
  value = "${aws_vpc.setup.id}"
}

output "vpc_main_route_table_id" {
  value = "${aws_vpc.setup.main_route_table_id}"
}

output "route_table_az1_private_id" {
  value = "${aws_route_table.private_az1.id}"
}

output "route_table_az2_private_id" {
  value = "${aws_route_table.private_az2.id}"
}

output "local_service_discovery_id" {
  value = "${aws_service_discovery_private_dns_namespace.local.id}"
}

output "ecs_spot_fleet_role_arn" {
  value = "${aws_iam_role.ec2_spot_fleet_role.arn}"
}

output "ecs_task_execution_role_arn" {
  value = "${aws_iam_role.ecs_task_execution_role.arn}"
}

output "ecs_cluster_id" {
  value = "${aws_ecs_cluster.setup.id}"
}

output "ecs_cluster_name" {
  value = "${aws_ecs_cluster.setup.name}"
}

output "subnet_az1_id" {
  value = "${aws_subnet.public_az1.id}"
}

output "subnet_az2_id" {
  value = "${aws_subnet.public_az2.id}"
}

output "subnet_az1_private_id" {
  value = "${aws_subnet.private_az1.id}"
}

output "subnet_az2_private_id" {
  value = "${aws_subnet.private_az2.id}"
}

output "security_group_private_id" {
  value = "${aws_security_group.private.id}"
}

output "security_group_public_id" {
  value = "${aws_security_group.public.id}"
}

output "alb_arn" {
  value = "${aws_alb.setup.arn}"
}

output "alb_listener_arn" {
  value = "${aws_alb_listener.https_listener.arn}"
}

output "ecs_instance_profile_name" {
  value = "${aws_iam_instance_profile.ecs.name}"
}

output "ecs_instance_key_pair_name" {
  value = "${aws_key_pair.instance_key_pair.key_name}"
}

output "bastion_private_ip" {
  value = "${aws_instance.bastion.private_ip}"
}
