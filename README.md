# Development cluster

Named after [Iona](https://en.ikipedia.org/wiki/Wikipedia:WikiProject_Scottish_Islands/Islands_by_population_densityw) is a scottish island with a population of ~120

* [Project Page](https://github.com/users/robinbryce/projects/2)
* [Firebase Project Page](https://console.firebase.google.com/project/iona-1/settings/general)
* [GCP Console](https://console.cloud.google.com/home/dashboard?project=iona-1)
* [Terraform Cloud Workspaces](https://app.terraform.io/app/robinbryce/workspaces)
* [thaumagen domain registrar](https://panel.bytemark.co.uk/domains/thaumagen.com/dns)
* [cluster landing page](https://iona.thaumagen.io/thaumagen/index.html)

Note: Diagrams in this document render using [Markdown Preview Enhanced](https://shd101wyy.github.io/markdown-preview-enhanced/#/) - which requires some kind of java installed. `apt-get install default-jre`

# Warts

* terraforms kubernetes provider doesn't seem smart enough to remove
  deployments part created by force canceled runs. After a force cancelation,
  its necessary to delete the envoy-lb or traefik deployments if the failed to
  individually apply
* terraform kubnernetes provider waits forever if a deployment doesn't come
  ready due to errors and needs to be force canceled

# Cluster Overview

![Iona Resources](http://www.plantuml.com/plantuml/proxy?cache=no&src=https://raw.githubusercontent.com/robinbryce/iona/main/iona-wbs.iuml)


![Iona Components](http://www.plantuml.com/plantuml/proxy?cache=no&src=https://raw.githubusercontent.com/robinbryce/iona/main/iona-components.iuml)

- static ip: a static ip address is created. the ingress node pool is
  restricted to a single instance node (vm) and kubeip is used to assign the
  static ip to *any* node in that pool
- ingress: instead of a loadbalancer (which is ~10GBP/month), we run an envoy proxy. the
  pod is configured to use the *host* network and so listens on the static ip
  assigned to the instance node by kube ip. 
- content proxy and tls termination: traefik.
- certmanager & letsencrypt provide automatic TLS certificates using dns01 challenges for the configured domain.
- traefik is configured with routes proxying for thaumagen.gitgithub.io so that static
  public content can be served directly from github.io (using GitHub Pages) but under the TLS certs of the clusters domains

- Cluster deployed and managed using terraform cloud via github
- Public static content hosted via github pages & proxied through traefik
- logging and monitoring enabled
- n2-standard-4 nodes
- NO LOAD BALANCER (reduces idle cost by ~50%). Envoy + Traefic based ingress.
  Achieve using a node pool specifically for ingress which is limited to a single
  vm. kubeip assigns the static ip to it.
- BUT HA/safe configuration for traefik so we can turn on a loadbalancer if we have traffic to justify that.
- The kubernetes resources for deploying traefik, cert-manager and envoy are
  considered part of the cluster and so are deployed and managed using the
  terraform kubernetes and helm providers
- The traefik routing is *not* part of the cluster. All services, middlewares, routes etc are configured using CRDs via kustomization (raw) manifests

# Plan

* [Project Page](https://github.com/users/robinbryce/projects/2)

# Build
# GKE Project checklist

## Enable API's

* [ ] Sign up for or login to google cloud.
* [ ] Create an empty GCP project, set the project id explicitly so that it matches the project name (just because it is fewer names to keep track of)
* [ ] Enable the Compute Engine API
* [ ] Enable Kubernetes Engine API
* [ ] Enable Cloud DNS API
* [ ] Enable Cloud Domains API
* [ ] Enable Secrets Manager API
* [ ] ~~~Enable Cloud Identity Aware Proxy~~~ not necessary
* [ ] Enable Identity Platform
* [ ] Service Networking API - to enable private service networking connection for managed redis
* [ ] Google Cloud Memorystore for Redis API
All can be found at APIs & Services / API Library except secrets manager.
Secrets Manager API can be found in the Security menu

## register a domain for the cluster

With cloud domains

## Create service account key for terraform

* [ ] Create a key for the compute engine default service account.
      IAM & Admin / Service Accounts ->
       Compute Engine Default Service account ->
        create key -> create as json save to local disc


## Configure roles and permissions for terraform

IAM & Admin / IAM -> Compute Engine Default Service account -> Add another role -> (pen icon to right)

* [ ] Editor
* [ ] Service Account Admin
* [ ] Secret Manager Admin
* [ ] Project IAM Admin
* [ ] Role Administrator
* [ ] Cloud Resource Manager
* [ ] Kubernetes Engine Service Agent - so that the kubernetes provider can
    create cluster roles and cluster role bindings

## Cluster DNS Verification

* [ ] verify a subdomain of thaumagen.com for iona.
    [see](https://cloud.google.com/identity/docs/add-cname#7334202)

## Identity Platform & Identity Aware Proxy

Aspects of the identiy platform that must be manualy configured for a new GCP
project before the tf can be applied.

* [ ] enabled identity plaform
* [ ] enable multi-tenancy
      Settings/Security/Allow tenants
* [ ] add the oauth domain
      Settings/Security/ add domain

Can users be managed via tf ?

## Create Client ID & Secret for each tenant

Create Oauth client ID in credentials api
* [ ] create client id and secret for use with the google provider [see](https://cloud.google.com/identity-platform/docs/web/google?hl=en_GB)

* [ ] add appropriate test user emails to the oauth consent screen (while the app is
    in test status public sign up isn't possible)

* [ ] add admin_tenant_client_id & _secret variables to the -authn workspace
* [ ] add public_tenant_client_id & _secret variables to the -authn workspace

https://cloud.google.com/identity-platform/docs/multi-tenancy
https://cloud.google.com/identity-platform/docs/multi-tenancy-quickstart
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/identity_platform_tenant
https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/identity_platform_oauth_idp_config


# Terraform Cloud Check List

## Create a workspace and link it to this repository

* [ ] Set the name of the workspace. It can be convenient if the cluster workspace project matches the gcp project name
* [ ] Set the terraform working directory to tf/cluster
* [ ] Enable 'only trigger runs when files in specified paths change' (it should select the working directory by default)
* [ ] Create the workspace

## Configure the workspace variables

* [ ] Create the workspace variable gke_project_id and set it to the name of your gcp project
* [ ] Add GOOGLE_CLOUD_KEYFILE_JSON as an environment variable with the value
      set to the 'single line' form of the compute engine default service key. `tr -d '\n' < project-sa-key.json`
* [ ] Create project_fqdn variable and set it to <project>.thaumagen.com (thaumagen.com is verified with gcp)

## Confirm the settings

* [ ] Go to the Settings tab
* [ ] Ensure execution mode is remote
* [ ] Enable auto apply
* [ ] Set terraform 1.1.2.
* [ ] (optional) Ensure your local terraform is the same version eg `tfswitch -b ~/.local/bin/terraform 1.1.2`

## Configure local client auth

before commiting and pushing the repo run terraform init & plan to verify the
initial setup. this is a remote operation intiated by the local client. it
needs an api token for terraform cloud. T

* [ ] goto user settings
* [ ] create api token
* [ ] create alocal file ~/.terraformrc
* [ ] add the token so it looks like

    credentials "app.terraform.io" {
      token = "THE-API-TOKEN"
    }

    ```
    cd tf/cluster
    terraform init
    terraform plan
    ```

# configure github access

* [ ] for personal accounts, go to settins/applications/terraform cloud, add
    this repository to the list of repositories terraform is allowed to access,
    add this repository to the list of repositories terraform is allowed to
    access
* [ ] For organisations, go to Settings/Installed Git Hub Apps and do the same

# Configure kubectl access

* [ ] gcloud --project=iona-1 container clusters get-credentials kluster
