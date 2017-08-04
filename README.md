# Kubernetes Helm Resource

Deploys [Helm](https://helm.sh/) charts on [Kubernetes](https://kubernetes.io/).

Note: Requires [Tiller](https://docs.helm.sh/using_helm/#installing-tiller) installed on the cluster.

## Source Configuration

* `cluster_url`: *Required.* The server of the cluster that points to the api server, e.g.
`https://api.<your-domain>.com`.

  Note: Protocol must be HTTPS

* `cluster_ca`: *Required.* Base64 encoded PEM.

* `token`: *Required.* Bearer token.

* `namespace`: *Required.* Namespace the chart will be installed to.

* `release_name`: *Required.* The name of the release.

  NOTE: Changing this value will create a new release under the new name. The old release won't be deleted.

## Behaviour

### `check`: Not implemented

This resource is mainly for deployments, there aren't really advantages in getting new versions.

### `in`: Not implemented

### `out`: Deploy an Helm chart

Deploys the chart using Helm. Every deploy creates a new revision of the same release.

#### Parameters

* `chart_dir`: *Required.* The path of a directory containing the helm chart.

* `set_values`: *Optional*. Override values defined in `values.yaml`.

  Example:

  ```yaml
  set_values:
    key1: value1
  ```

* `dry_run`: *Optional.* Simulate the installation. Default `false`.

* `recreate_pods`: *Optional.* Force Pod recreation. Default `false`.

* `force`: *Optional.* Force resource update (through delete/recreate) if needed. Default `false`.

* `wait_until_ready`: *Optional.* Wait until all resources, and minimum number of Pods in Deployment are in a ready state before marking the release as successful.

* `timeout`: *Optional.* Time in seconds to wait for the operation. Default `300`.

## Example

Assuming you have your helm chart directory in a directory called `helm` in your git repository.

```yaml
resource_types:
- name: helm
  type: docker-image
  source:
    repository: mnsplatform/concourse-helm-resource

resources:
- name: helm
  type: helm
  source:
    cluster_url: # ...
    cluster_ca: # ...
    token: # ...
    namespace: # ...
    release_name: # ...

- name: git-resource
  type: git
  source: # ...

jobs:
- name: deploy-helm
  plan:
  - get: git-resource

  - put: helm
    params:
      chart_dir: repo/helm
      # ...
```

## Credits

This resource is based on [linkyard/concourse-helm-resource](https://github.com/linkyard/concourse-helm-resource)
