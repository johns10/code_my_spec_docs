# ExAws.Operation

An operation to perform on AWS.

This module defines a protocol for executing operations on AWS. ExAws ships with
several different modules that each implement the `ExAws.Operation` protocol. These
modules each handle one of the broad categories of AWS service types:

- `ExAws.Operation.JSON`
- `ExAws.Operation.Query`
- `ExAws.Operation.RestQuery`
- `ExAws.Operation.S3`

ExAws works by creating a data structure that implements this protocol, and then
calling `perform/2` on it.

## perform(operation, config)

Perform a request on AWS.

The operation is synchronous, returning a response or an error.

## Example

    %ExAws.Operation.JSON{
      data: %{},
      headers: [
        {"x-amz-target", "DynamoDB_20120810.ListTables"},
        {"content-type", "application/x-amz-json-1.0"}
      ],
      http_method: :post,
      params: %{},
      path: "/",
      service: :dynamodb,
    } |> ExAws.Operation.perform(ExAws.Config.new(:dynamodb))

## stream!(operation, config)

Perform a *streaming* request on AWS.

## t/0

All the types that implement this protocol.