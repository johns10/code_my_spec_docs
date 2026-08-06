# CodeMySpec.Provisioning.Registry

Where built images live, and how they stop costing money.

A registry backed by the object storage the storage step already provisions, so retention is the bucket lifecycle rule we have written rather than a new service to garbage-collect. Deploys pull from here, which is the point: nothing in the deploy path needs a GitHub credential, and a GitHub outage does not stop a deploy.

## Type

module
