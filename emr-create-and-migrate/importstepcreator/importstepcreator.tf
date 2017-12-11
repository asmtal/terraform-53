# AWS PROVIDERS
# Default provider (used if provider not specified in resource definition)
provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

# EMR definition by cloudformation stack
resource "aws_cloudformation_stack" "emrstep" {
  name = "emrstep"
  depends_on = ["aws_cloudformation_stack.tfEMR"]
  # newclusterid = "$aws_cloudformation_stack.tfEMR.EMRCY325"
  disable_rollback = "true"
  tags    = { Name= "tfEMRstep" }
  timeout_in_minutes = "120"
  template_body = <<STACK
{
  "AWSTemplateFormatVersion": "2010-09-09",
  "Resources": {
    "DistCPS32Dest": {
      "Type": "AWS::EMR::Step",
      "Properties": {
        "ActionOnFailure": "CANCEL_AND_WAIT",
        "HadoopJarStep": {
          "Args": [
            "hadoop",
            "distcp",
            "s3a://hadoop-warehouse-migration/",
            "hdfs:///user/hive/warehouse_migration/*"
          ],
          "Jar": "command-runner.jar",
          "StepProperties": []
        },
        "JobFlowId": "${var.destination_cluster}",
        "Name": "DistCP migration data from S3 to Destination Cluster"
      }
    }
  },
  "Outputs": {
    "STEPDistCPS32Dest": {
      "Value": {
        "Ref": "DistCPS32Dest"
      }
    }
  }
}
STACK
}


output "importstep" {
    value = "${aws_cloudformation_stack.emrstep.outputs}"
}