<h2> Caller module example repository</h2>

This repository contains TF scripts of caller module for the provision of a simple S3 bucket. 

<p>

Sample S3 Rego policy

```
import input as tfplan

# Consider exactly these resource types in calculations
resource_types = {"aws_s3_bucket"}

# acceptable score for automated authorization
blast_radius = 5

# weights assigned for each operation on each resource-type
weights = {
    "aws_autoscaling_group": {"delete": 100, "create": 10, "modify": 1},
    "aws_s3_bucket": {"acl": 10, "ssl": 10, "logs": 5, "sse": 10, "tags": 10}
}

# Enforce S3 bucket region to eu-central-1
s3_region_change[resource_type] = num {
    some resource_type
    resource_types[resource_type]
    all := resources[resource_type]
    creates := [res |  res:= all[_]; res.change.after.region != "eu-central-1"]
    num := count(creates)
}

```

OPA commands

```
1. terraform init
2. terraform plan --out tfplan.binary
3. terraform show -json tfplan.binary > tfplan.json
# command to find the score 
4. opa eval --format pretty --data s3-validate.rego --input tfplan.json "data.terraform.analysis.score"
# command to find true / false flag.
5. opa eval --format pretty --data s3-validate.rego --input tfplan.json "data.terraform.analysis.authz"
# command to get list of errors, in this scenario you have to provide the rego file name as well
6. opa eval -f pretty --explain=notes  --data rds-validate.rego --input tfplan.json "authorized = data.terraform.analysis.authz; violations = data.terraform.analysis.violation"
```
Example result from command # 6

```
+------------+---------------------------+
| authorized |        violations         |
+------------+---------------------------+
| false      | ["missing required tags"] |
+------------+---------------------------+
```


Refer to this article more detailed explanation and for more AWS solutions . 
http://i-cloudconsulting.com/open-policy-agent-opa-terraform-example/
