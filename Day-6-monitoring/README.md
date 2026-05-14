# Kubernetes Monitoring Setup using Prometheus, Grafana and PagerDuty

# Overview

This project demonstrates how to set up a complete Kubernetes monitoring and alerting stack using:

* Prometheus
* Grafana
* PagerDuty
* Helm
* Kubernetes

The setup helps monitor:

* Cluster health
* CPU usage
* Memory usage
* Pod metrics
* Network traffic
* Node status
* Kubernetes workloads

Alerts are configured using PagerDuty for real-time incident management.

---

# Architecture

## Monitoring Workflow

Kubernetes Cluster → Prometheus → Grafana → PagerDuty Alerts

---

# Components Explanation

## 1. Prometheus

Prometheus is an open-source monitoring and alerting tool.

Responsibilities:

* Scrapes metrics from Kubernetes
* Stores metrics as time-series data
* Collects node and pod statistics
* Supports alerting rules

Features:

* Pull-based monitoring
* Time-series database
* Powerful PromQL queries
* Kubernetes native

---

## 2. Grafana

Grafana is an open-source visualization platform.

Responsibilities:

* Visualize Prometheus metrics
* Create dashboards
* Create alert rules
* Monitor cluster health visually

Features:

* Interactive dashboards
* Real-time graphs
* Alerting support
* Multiple datasource support

---

## 3. Alertmanager

Alertmanager handles alerts generated from Prometheus or Grafana.

Responsibilities:

* Sends alerts to external systems
* Alert grouping
* Deduplication
* Notification routing

Supported Integrations:

* PagerDuty
* Slack
* Email
* Microsoft Teams
* Webhooks

---

## 4. PagerDuty

PagerDuty is an incident management platform.

Responsibilities:

* Receives alerts
* Creates incidents
* Sends notifications
* Escalation management

---

# Why Use Helm?

Helm is a Kubernetes package manager.

Benefits:

* Easy installation
* One-command deployment
* Faster setup
* Standardized configurations
* Easy upgrades and rollback

---

# Prerequisites

Before starting ensure you have:

## Infrastructure

* EC2 instance (t2.micro or above)
* Kubernetes cluster
* kubectl configured
* Internet access

## Security Group Configuration

Allow:

* Port 3000 for Grafana
* Port 9090 for Prometheus
* Port 80/443 if using LoadBalancer
* SSH access (22)

---

# Install Helm

If Helm is not installed, run the following commands:

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

Verify installation:

```bash
helm version
```

---

# Step 1: Add Helm Stable Repository

```bash
helm repo add stable https://charts.helm.sh/stable
```

Update repositories:

```bash
helm repo update
```

---

# Step 2: Add Prometheus Community Helm Repository

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```

Update repositories:

```bash
helm repo update
```

---

# Step 3: Create Namespace

Create namespace for monitoring stack:

```bash
kubectl create namespace prometheus
```

Verify:

```bash
kubectl get ns
```

---

# Step 4: Install Prometheus Stack

Install kube-prometheus-stack using Helm:

```bash
helm install stable prometheus-community/kube-prometheus-stack -n prometheus
```

---

# What is kube-prometheus-stack?

This Helm chart installs:

* Prometheus
* Grafana
* Alertmanager
* Node Exporter
* kube-state-metrics
* Prometheus Operator

All monitoring components are deployed together.

---

# Step 5: Verify Installation

Check pods:

```bash
kubectl get pods -n prometheus
```

Expected Components:

```text
prometheus
alertmanager
grafana
node-exporter
kube-state-metrics
```

All pods should be in Running state.

---

# Step 6: Check Services

```bash
kubectl get svc -n prometheus
```

You will see services for:

* Prometheus
* Grafana
* Alertmanager

---

# Understanding Service Types

## ClusterIP

Accessible only inside Kubernetes cluster.

---

## NodePort

Accessible through node IP and port.

---

## LoadBalancer

Creates external load balancer.

Recommended for cloud environments.

---

# Step 7: Expose Prometheus using LoadBalancer

Edit Prometheus service:

```bash
kubectl edit svc stable-kube-prometheus-sta-prometheus -n prometheus
```

Change:

```yaml
type: ClusterIP
```

To:

```yaml
type: LoadBalancer
```

Save the file.

---

# Verify LoadBalancer

```bash
kubectl get svc -n prometheus
```

Wait until EXTERNAL-IP is assigned.

Example:

```text
EXTERNAL-IP: a1b2c3d4.amazonaws.com
```

---

# Access Prometheus UI

Open browser:

```text
http://EXTERNAL-IP:9090
```

---

# Prometheus UI Features

Prometheus UI helps:

* Execute PromQL queries
* Monitor targets
* View alerts
* Explore metrics

However, visualization is limited.

Grafana provides better dashboards.

---

# Step 8: Expose Grafana using LoadBalancer

Edit Grafana service:

```bash
kubectl edit svc stable-grafana -n prometheus
```

Change:

```yaml
type: ClusterIP
```

To:

```yaml
type: LoadBalancer
```

Save the file.

---

# Verify Grafana Service

```bash
kubectl get svc -n prometheus
```

Wait for EXTERNAL-IP.

---

# Access Grafana

Open browser:

```text
http://EXTERNAL-IP
```

---

# Step 9: Get Grafana Credentials

Default username:

```text
admin
```

Get password:

```bash
kubectl get secret --namespace prometheus stable-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

Login using:

* Username: admin
* Password: retrieved password

---

# Grafana Dashboard Setup

# Step 10: Import Dashboard

Inside Grafana:

* Go to Dashboards
* Click Import
* Import dashboard ID

Popular dashboard IDs:

| Dashboard                     | ID   |
| ----------------------------- | ---- |
| Kubernetes Cluster Monitoring | 315  |
| Node Exporter Full            | 1860 |
| Kubernetes Pods Monitoring    | 6417 |

---

# Select Prometheus Datasource

Choose:

```text
Prometheus
```

Click:

```text
Import
```

---

# Metrics You Can Monitor

## Cluster Metrics

* CPU usage
* Memory usage
* Disk usage
* Network traffic

---

## Pod Metrics

* Pod restart count
* Pod CPU usage
* Pod memory usage
* Pod status

---

## Node Metrics

* Node availability
* Node CPU load
* Node memory
* Filesystem usage

---

## Container Metrics

* CPU limits
* Resource requests
* Container restarts
* Network bandwidth

---

## HPA Metrics

* Replica scaling
* CPU thresholds
* Autoscaling events

---

# Monitoring Features

You can monitor:

1. CPU and RAM usage
2. Namespace resource usage
3. Pod history
4. Network traffic
5. Resource limits
6. Application health
7. Cluster health

---

# Alternative Deployment Methods

## Method 1: Manual YAML Configuration

Create all manifests manually:

* Deployments
* ConfigMaps
* Services
* StatefulSets

Then apply in order.

---

## Method 2: Prometheus Operator

Prometheus Operator automates:

* Prometheus deployment
* Monitoring configuration
* Alerting rules
* Service discovery

---

## Method 3: Helm Chart

Recommended method.

Benefits:

* Easy setup
* Faster deployment
* Production ready
* Standardized configuration

---

# Configuring Alerts with PagerDuty

# What is PagerDuty?

PagerDuty is an incident response platform.

Used for:

* Alert management
* Incident tracking
* Escalation handling
* Notifications

---

# Step 1: Login to PagerDuty

Open:

```text
https://www.pagerduty.com/
```

Login using your credentials.

---

# Step 2: Create New Service

Inside PagerDuty:

* Go to Services
* Click + New Service

Enter:

* Service name
* Description

---

# Step 3: Select Integration Type

Under Integration Type choose:

```text
Events API v2
```

Click:

```text
Add Service
```

---

# Step 4: Obtain Integration Key

After service creation:

* Open Service Configuration
* Scroll to Integrations
* Copy Integration Key

Example:

```text
abcd1234efgh5678
```

This key is used by Grafana to send alerts.

---

# Step 5: Configure PagerDuty in Grafana

## Add Contact Point

Inside Grafana:

* Go to Alerting
* Contact Points
* Add Contact Point

---

# Configure Contact Point

Name:

```text
PagerDuty Alerts
```

Type:

```text
PagerDuty
```

Paste:

```text
Integration Key
```

Click:

```text
Save
```

---

# Step 6: Create High CPU Usage Alert

Inside Grafana:

* Go to Alerting
* Alert Rules
* Create Alert Rule

---

# Alert Rule Configuration

## Alert Name

```text
High CPU Usage Alert
```

---

# Query

```promql
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

---

# Condition

```text
When last value is above 90
```

Duration:

```text
1 minute
```

---

# Notifications

Select:

```text
PagerDuty Alerts
```

Click:

```text
Save Alert Rule
```

---

# Step 7: Test Alerts

Inside Grafana:

* Go to Alert Rules
* Click Test Rule

If CPU exceeds threshold:

* Alert triggers
* PagerDuty incident created

---

# PagerDuty Incident Workflow

CPU High → Grafana Alert → PagerDuty Incident → Notification Sent

---

# Resolving Alerts

Once issue is resolved:

* Open PagerDuty incident
* Mark incident as resolved

---

# Prometheus Architecture

## Components

### Prometheus Server

Responsible for:

* Metric collection
* Time-series storage
* Query processing

---

### Node Exporter

Collects:

* CPU metrics
* Memory metrics
* Disk metrics
* Network metrics

---

### kube-state-metrics

Collects Kubernetes object metrics:

* Pods
* Deployments
* Nodes
* ReplicaSets

---

### Alertmanager

Handles alerts and notifications.

---

# Important Ports

| Component     | Port |
| ------------- | ---- |
| Prometheus    | 9090 |
| Grafana       | 3000 |
| Alertmanager  | 9093 |
| Node Exporter | 9100 |

---

# Common Commands

# Check Pods

```bash
kubectl get pods -n prometheus
```

---

# Check Services

```bash
kubectl get svc -n prometheus
```

---

# Check Helm Releases

```bash
helm list -n prometheus
```

---

# Delete Stack

```bash
helm uninstall stable -n prometheus
```

---

# Delete Namespace

```bash
kubectl delete namespace prometheus
```

---

# Troubleshooting

# Pods Not Running

Check:

```bash
kubectl describe pod POD_NAME -n prometheus
kubectl logs POD_NAME -n prometheus
```

---

# EXTERNAL-IP Pending

Possible Reasons:

* LoadBalancer not supported
* Cloud provider issue
* Missing permissions

Alternative:

Use NodePort.

---

# Grafana Login Failed

Reset password:

```bash
kubectl get secret --namespace prometheus stable-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

---

# Prometheus Targets Down

Open:

```text
http://PROMETHEUS-IP:9090/targets
```

Check failed targets.

---

# Best Practices

## Use Persistent Storage

Store Prometheus data permanently.

---

## Enable Authentication

Protect Grafana and Prometheus.

---

## Use Ingress Controller

Instead of exposing services directly.

---

## Configure TLS

Secure monitoring endpoints.

---

## Use Resource Limits

Avoid resource exhaustion.

---

# Production Recommendations

Recommended setup:

* EKS or AKS cluster
* Helm deployment
* Ingress controller
* Persistent volumes
* External DNS
* TLS certificates
* PagerDuty integration
* Slack alerts

---

# Advantages of this Setup

* Centralized monitoring
* Real-time metrics
* Alerting system
* Visual dashboards
* Kubernetes visibility
* Incident management
* Scalable architecture

---

# Final Workflow Summary

1. Install Helm
2. Add Helm repositories
3. Install kube-prometheus-stack
4. Verify pods and services
5. Expose Prometheus and Grafana
6. Access Grafana UI
7. Import dashboards
8. Configure PagerDuty
9. Create alerts
10. Monitor Kubernetes cluster

---

# Conclusion

Using Prometheus, Grafana, and PagerDuty together provides a complete Kubernetes monitoring and alerting solution.

Prometheus collects and stores metrics.
Grafana visualizes metrics using dashboards.
PagerDuty manages incidents and notifications.

This setup helps DevOps and SRE teams monitor infrastructure effectively and respond quickly to production issues.
