# Usage
This is a terraform to create a redshift cluster in it's own VPC.

```
terraform apply -var 'tag_name=...' -var 'tag_application=...' -var 'tag_team=...' -var 'tag_environment=dev' -var 'tag_contact_email=...' -var 'cluster_id=...' -var 'db_name=...' -var 'master_username=...' -var 'encrypted=true' -var 'master_password=...'
```

**Please note that the security group in main.tf allows everyone to access your Redshift database so please update the ingress accordingly to tighten things down.  It does create things in its own VPC so you'll only be shooting yourself in the foot but I wanted to preface this**


## Done outside of Terraform
- Add a cloud watch alert to send via SMS to your contact when the storage size goes over 50%

## Variables that can be passed in

*profile*
```
-var 'profile=<AWS profile.  defaults to default>' 
```

*tag_name*
```
-var 'tag_name=<Name>' 
```

*tag_application*
```
-var 'tag_application=<Application name>' 
```

*tag_team*
```
-var 'tag_team=<Team name>' 
```

*tag_environment*
```
-var 'tag_environment=<Environment(dev, qa, prod)>' 
```

*tag_contact*
```
-var 'tag_contact_email=<Email address of main contact>' 
```

*cluster_id*
```
-var 'cluster_id=<Cluster name>' 
```

*db_name*
```
-var 'db_name=<Cluster database name' 
```

*master_username*
```
-var 'master_username=<Cluster master user>' 
```

*master_password*
```
-var 'master_password=<Cluster master password>'
```

*region*
```
-var 'region=<AWS region(us-east-1)>'
```

*availability_zone*
```
-var 'availability_zone=<Availability Zone in above AWS region(us-east-1a)>'
```

*encrypted*
```
-var 'encrypted=<Whether to encrypt database(true)>'
```

*skip_final_snapshot*
```
-var 'skip_final_snapshot=<Whether to skip final snapshot which may not be needed for testing(false)>'
```

*number_of_nodes*
```
-var 'number_of_nodes=<Number of nodes in cluster(3)>'
```

*cluster_type*
```
-var 'cluster_type=<Cluster type. Single node or multi node(multi-node)>'
```

*node_type*
```
-var 'node_type=<Node type(dc1.large)>'
```