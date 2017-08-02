#!/bin/bash
set -eo pipefail

readonly \
  c_reset="\e[0m"
  c_blue="\e[34m" \
  c_red="\e[31m"

die() { printf "${c_red}ERROR: %b" "$*\n"; exit 1; }
error_if_empty() { [ -n "${!1:-}" ] || die "Invalid payload (missing $1)"; }
info() { printf "${c_blue}%b${c_reset}" "$*\n"; }

# kubectl config setup
set_cluster_config() {
  payload="$1"

  cluster_url=$(jq -r '.source.cluster_url // ""' < "$payload")
  error_if_empty "cluster_url"

  if ! [[ "$cluster_url" =~ ^https://[^\.]+\.[^.]+ ]]; then
    die "Invalid url format"
  fi

  cluster_ca=$(jq -r '.source.cluster_ca // ""' < "$payload")
  token=$(jq -r '.source.token // ""' < "$payload")
  error_if_empty cluster_ca
  error_if_empty token

  mkdir -p /root/.kube

  ca_path="/root/.kube/ca.pem"
  cluster_name="default"
  cluster_user="user"

  echo "Decoding cluster certificate authority..."
  echo "$cluster_ca" | base64 -d > "$ca_path"

  kubectl config set-cluster $cluster_name --server="$cluster_url" --certificate-authority="$ca_path"
  kubectl config set-credentials $cluster_user --token="$token"

  kubectl config set-context $cluster_name --cluster=$cluster_name --user=$cluster_user --namespace="$namespace"
  kubectl config use-context $cluster_name

  info "Verifying connectivity to the cluster..."
  kubectl cluster-info
}

helm_init() {
  helm init --client-only &>/dev/null
}

setup_resource() {
  info "Setting cluster configuration..."
  set_cluster_config "$1"

  info "Initialising helm..."
  helm_init
}
