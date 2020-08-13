package terraform.analysis

import input as tfplan

########################
# Parameters for Policy
########################

# acceptable score for automated authorization
blast_radius = 5

# weights assigned for each operation on each resource-type
weights = {
    "aws_db_subnet_group": {"delete": 100, "create": 10, "modify": 1},
    "aws_db_instance": {"ssl": 10, "logs": 5, "sse": 10, "tags": 10, "region":10, "backup":10}
}

# Consider exactly these resource types in calculations
resource_types = {"aws_db_instance"}

minimum_tags = {"Name", "app:name"}

violations = data.terraform.analysis.violation
authorized = data.terraform.analysis.authz


#########
# Policy
#########

# Authorization holds if score for the plan is acceptable and no changes are made to IAM
#default authz = false
authz {
    score < blast_radius
    not touches_iam
}

# Compute the score for a Terraform plan as the weighted sum of deletions, creations, modifications
score = s {
    all := [ x |
            some resource_type
            crud := weights[resource_type];
            tags_chg := crud["tags"] * rds_tags_change[resource_type];
            sse_chg := crud["sse"] * rds_encryption_change[resource_type];
            backup_chg := crud["backup"] * rds_backup_retention_change[resource_type];
            x := tags_chg + sse_chg + backup_chg
    ]
    s := sum(all)
}

# Whether there is any change to IAM
touches_iam {
    all := resources["aws_iam"]
    count(all) > 0
}


# Whether there is any change to IAM
touches_sg {
    all := resources["aws_security_group"]
    count(all) > 0
}

####################
# Terraform Library
####################

# list of all resources of a given type
resources[resource_type ] = all {
    some resource_type
    resource_types[resource_type]
    all := [name |
        name:= tfplan.resource_changes[_]
        name.type == resource_type
    ]
}


violation["missing required tags"] {
   rds_tags_change[resource_types[_]] > 0
}

violation["missing rds backup rentetion period"] {
   rds_backup_retention_change[resource_types[_]] > 0
}

violation["missing rds encryption"] {
   rds_encryption_change[resource_types[_]] > 0
}


# RDS  missing tags - refer to variable minimum_tags
rds_tags_change[resource_type] = num {
    some resource_type
    resource_types[resource_type]
    all := resources[resource_type]
    modifies := [res |  res:= all[_]; not tags_contain_proper_keys(res.change.after.tags)]
    num := count(modifies)
    #trace(modifies)
}


# RDS backup retention period is enabled 
# we can also check for retrntion period if that is a required validation.
rds_backup_retention_change[resource_type] = num {
    some resource_type
    resource_types[resource_type]
    all := resources[resource_type]
    modifies := [res |  res:= all[_]; not res.change.after.backup_retention_period1]
    num := count(modifies)
}


# RDS kms encryption is enabled
rds_encryption_change[resource_type] = num {
    some resource_type
    resource_types[resource_type]
    all := resources[resource_type]
    modifies := [res |  res:= all[_]; not res.change.after_unknown.kms_key_id1]
    num := count(modifies)
}

#helper functions 
tags_contain_proper_keys(tags) {
    keys := {key | tags[key]}
    leftover := minimum_tags - keys
    leftover == set()
}