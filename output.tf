output "kinesis_name" {
  value = "${aws_kinesis_stream.stream_test.name}"
}

output "role_name" {
  value = "${aws_iam_role.test_cross_account_role.name}"
}
