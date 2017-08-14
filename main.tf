provider "aws" {
  region     = "${var.region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

resource "aws_kinesis_stream" "stream_test" {
  name        = "${var.name_prefix}${var.stream_name}"
  shard_count = 1

  tags {
    Name = "${var.name_prefix}${var.stream_name}"
  }
}

resource "aws_iam_role" "test_cross_account_role" {
  name        = "${var.name_prefix}${var.role_name}"
  description = "terraform role for cross account access to kinesis"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "AWS": "arn:aws:iam::${var.trusted_id}:root"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
}
EOF
}

data "aws_iam_policy_document" "policy_kinesis_full_access" {
  statement {
    actions = [
      "kinesis:*",
    ]

    resources = [
      "arn:aws:kinesis:*:${var.account_id}:stream/${aws_kinesis_stream.stream_test.name}",
    ]
  }
}

resource "aws_iam_policy" "kinesis_stream_full_access" {
  name       = "${aws_kinesis_stream.stream_test.name}_full_access"
  policy     = "${data.aws_iam_policy_document.policy_kinesis_full_access.json}"
  depends_on = ["aws_kinesis_stream.stream_test", "aws_iam_role.test_cross_account_role"]
}

resource "aws_iam_role_policy_attachment" "policy_for_kinesis_attachment" {
  role       = "${aws_iam_role.test_cross_account_role.name}"
  policy_arn = "${aws_iam_policy.kinesis_stream_full_access.arn}"
  depends_on = ["aws_iam_role.test_cross_account_role", "aws_iam_policy.kinesis_stream_full_access"]
}
