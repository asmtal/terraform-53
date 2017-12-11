# AWS PROVIDERS
# Default provider (used if provider not specified in resource definition)
provider "aws" {
  access_key = ""
  secret_key = ""
  region = "us-west-2"
}

# EMR definition by cloudformation stack
resource "aws_cloudformation_stack" "tfEMR" {
  name = "tfemrrr"
  # DO_NOTHING, ROLLBACK, or DELETE
#  on_failure = "DO_NOTHING"
  disable_rollback = "true"
  tags    = { Name= "tfEMRsmall" }
  timeout_in_minutes = "120"
  template_body = <<STACK
{
  "Resources": {
    "tfEMR": {
      "Type": "AWS::EMR::Cluster",
      "Properties": {
        "Name": "Recalc_terraform",
        "ReleaseLabel": "emr-4.7.2",
        "JobFlowRole": "EMR_EC2_DefaultRole",
        "ServiceRole": "EMR_DefaultRole",
        "VisibleToAllUsers": true,
        "Configurations": [
          {
            "Classification": "emrfs-site",
            "ConfigurationProperties": {
              "fs.s3.consistent.metadata.tableName": "EmrFSMetadata",
              "fs.s3.consistent.retryPeriodSeconds": "10",
              "fs.s3.consistent": "true",
              "fs.s3.consistent.retryCount": "5"
            },
            "Configurations": [
              ]
          }
          ],
        "Instances": {
          "MasterInstanceGroup": {
            "InstanceCount": "1",
            "InstanceType": "c3.8xlarge",
            "Name": "Master"
          },
          "CoreInstanceGroup": {
            "InstanceCount": "2",
            "InstanceType": "c3.8xlarge",
            "Name": "Core"
          },
          "TerminationProtected": false,
          "Ec2KeyName": "MCAnalyticsEMR",
          "Ec2SubnetId": "subnet-17276e4e",
          "EmrManagedMasterSecurityGroup": "sg-570fcd30",
          "EmrManagedSlaveSecurityGroup": "sg-540fcd33"
        },
        "Applications": [
          {
            "Name": "Hadoop"
          },
          {
            "Name": "Hive"
          },
          {
            "Name": "Spark"
          },
          {
            "Name": "Ganglia"
          },
          {
            "Name": "Presto-Sandbox"
          },
          {
            "Name": "Zeppelin-Sandbox"
          }
        ]
      },
      "Metadata": {
        "AWS::CloudFormation::Designer": {
          "id": "62fb550e-977f-4745-839b-72bb270d400f"
        }
      }
    }
  },
  "Metadata": {
    "AWS::CloudFormation::Designer": {
      "62fb550e-977f-4745-839b-72bb270d400f": {
        "size": {
          "width": 60,
          "height": 60
        },
        "position": {
          "x": 60,
          "y": 90
        },
        "z": 1,
        "embeds": []
      }
    }
  },
  "Outputs": {
    "MasterPublicDNS": {
      "Description": "MasterPublicDNS",
      "Value": {
        "Fn::GetAtt": [
          "tfEMR",
          "MasterPublicDNS"
        ]
      }
    }
  }
}
STACK
}
