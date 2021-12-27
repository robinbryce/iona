# Development cluster

Named after [Iona](https://en.ikipedia.org/wiki/Wikipedia:WikiProject_Scottish_Islands/Islands_by_population_densityw) is a scottish island with a population of ~120

# Cluster features

- logging and monitoring enabled
- e2-standard-2 nodes
-

# Plan

enable monitoring and logging

what to set monitoring_service to for google_container_cluster

# Build

# GKE Project checklist

## Enable API's

* [ ] Sign up for or login to google cloud.
* [ ] Create an empty GCP project, set the project id explicitly so that it matches the project name (just because it is fewer names to keep track of)
* [ ] Enable the Compute Engine API
* [ ] Enable Kubernetes Engine API
* [ ] Enable Cloud DNS API
* [ ] Enable Secrets Manager API

All can be found at APIs & Services / API Library except secrets manager.
Secrets Manager API can be found in the Security menu

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


