## Comparison Test #1: Generating Terraform Code for EKS Clusters with Audit Logging

For our first test we will be asking our tools to create an Amazon Elastic Kubernetes Service (EKS) cluster using Terraform with audit logging enabled.

**Objective:** Evaluate whether our AI tools can effectively generate Terraform configurations that:

- Enable audit logging for EKS clusters.
- Create a CloudWatch log group for logging management.

**Evaluation Criteria:**

1. **Correctness**: Ensures audit logging is enabled and a CloudWatch log group is created.
2. **Completeness**: A comprehensive setup of necessary resources and configurations.
3. **Usability**: Code structure should be readable, reusable, and maintainable.

For each of the tests we will ask the tool a variation of the below question:

> Can you write terraform code to create a EKS cluster with audit enabled?
>