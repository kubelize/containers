# Gomplate ArgoCD CMP Plugin

This directory contains the configuration and files needed to run a Gomplate-based Config Management Plugin (CMP) for ArgoCD.

## Overview

The Gomplate CMP plugin allows ArgoCD to process templates using [gomplate](https://gomplate.ca/), a powerful template renderer that supports multiple data sources including environment variables, files, HTTP endpoints, cloud metadata services, and more.

## Files

- `gomplate-cmp.yaml` - ArgoCD CMP configuration for gomplate
- `Dockerfile.gomplate` - Docker image definition for the gomplate CMP
- `gomplate-entrypoint.sh` - Entrypoint script with environment setup

## Features

- **Template Discovery**: Automatically detects `.gotmpl` and `.tmpl` files
- **Config Support**: Supports `gomplate.yaml` or `.gomplate.yaml` configuration files
- **Environment Integration**: Access to ArgoCD environment variables
- **Kubernetes Integration**: Automatic service account token and namespace detection
- **Multiple Data Sources**: Support for AWS, Vault, and other external data sources
- **Flexible Output**: Processes templates and outputs YAML manifests

## Usage

### Template Files

Create template files with `.gotmpl` or `.tmpl` extensions:

```yaml
# deployment.yaml.gotmpl
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ env.Getenv "ARGOCD_APP_NAME" "myapp" }}
  namespace: {{ env.Getenv "ARGOCD_APP_NAMESPACE" "default" }}
spec:
  replicas: {{ env.Getenv "REPLICAS" "1" | conv.ToInt }}
  selector:
    matchLabels:
      app: {{ env.Getenv "ARGOCD_APP_NAME" "myapp" }}
  template:
    metadata:
      labels:
        app: {{ env.Getenv "ARGOCD_APP_NAME" "myapp" }}
    spec:
      containers:
      - name: app
        image: {{ env.Getenv "IMAGE_NAME" }}:{{ env.Getenv "IMAGE_TAG" "latest" }}
        ports:
        - containerPort: 8080
```

### Configuration File

Optionally, create a `gomplate.yaml` configuration file:

```yaml
# gomplate.yaml
inputFiles:
  - "templates/*.gotmpl"
outputMap: |
  {{ .in | strings.TrimSuffix ".gotmpl" }}

datasources:
  config:
    url: file://config.yaml
  secrets:
    url: file://secrets.yaml

context:
  app_name: "{{ env.Getenv \"ARGOCD_APP_NAME\" }}"
  namespace: "{{ env.Getenv \"ARGOCD_APP_NAMESPACE\" }}"
```

### Environment Variables

The plugin provides access to ArgoCD environment variables and additional data sources:

#### ArgoCD Variables
- `ARGOCD_APP_NAME` - Application name
- `ARGOCD_APP_NAMESPACE` - Target namespace
- `ARGOCD_APP_REVISION` - Git revision
- `ARGOCD_APP_SOURCE_PATH` - Source path in repository
- `ARGOCD_APP_SOURCE_REPO_URL` - Source repository URL
- `ARGOCD_APP_SOURCE_TARGET_REVISION` - Target revision

#### Plugin Variables
- `GOMPLATE_TIMEOUT` - Template processing timeout (default: 30s)
- `GOMPLATE_LOG_LEVEL` - Log level (default: info)
- `GOMPLATE_OUTPUT_DIR` - Output directory (default: current directory)

#### Kubernetes Integration
- `GOMPLATE_K8S_TOKEN` - Service account token (auto-detected)
- `GOMPLATE_K8S_NAMESPACE` - Service account namespace (auto-detected)

## Building the Plugin

Build the Docker image:

```bash
docker build -f argocd-cmp/Dockerfile.gomplate -t your-registry/gomplate-cmp:latest .
```

## ArgoCD Configuration

Register the plugin in your ArgoCD configuration:

```yaml
# argocd-repo-server deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: argocd-repo-server
spec:
  template:
    spec:
      containers:
      - name: argocd-repo-server
        # ... existing configuration
      - name: gomplate-cmp
        image: your-registry/gomplate-cmp:latest
        securityContext:
          runAsNonRoot: true
          runAsUser: 999
        volumeMounts:
        - name: var-files
          mountPath: /var/run/argocd
        - name: plugins
          mountPath: /home/argocd/cmp-server/plugins
        - name: tmp
          mountPath: /tmp
```

## Examples

### Simple Template

```yaml
# service.yaml.gotmpl
apiVersion: v1
kind: Service
metadata:
  name: {{ env.Getenv "ARGOCD_APP_NAME" }}
  namespace: {{ env.Getenv "ARGOCD_APP_NAMESPACE" }}
spec:
  selector:
    app: {{ env.Getenv "ARGOCD_APP_NAME" }}
  ports:
  - port: {{ env.Getenv "SERVICE_PORT" "80" | conv.ToInt }}
    targetPort: {{ env.Getenv "TARGET_PORT" "8080" | conv.ToInt }}
```

### Advanced Template with External Data

```yaml
# configmap.yaml.gotmpl
{{- $config := datasource "config" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ env.Getenv "ARGOCD_APP_NAME" }}-config
  namespace: {{ env.Getenv "ARGOCD_APP_NAMESPACE" }}
data:
  {{- range $key, $value := $config }}
  {{ $key }}: {{ $value | toYAML }}
  {{- end }}
```

## Troubleshooting

### Common Issues

1. **Template Not Found**: Ensure your template files have `.gotmpl` or `.tmpl` extensions
2. **Environment Variables**: Check that required environment variables are set in ArgoCD
3. **Permissions**: Verify the CMP container has access to necessary volumes and secrets

### Debug Mode

Enable debug logging by setting the environment variable:

```yaml
env:
- name: GOMPLATE_LOG_LEVEL
  value: debug
```

## Data Sources

Gomplate supports many data sources out of the box:

- **Environment Variables**: `env://`
- **Files**: `file://path/to/file`
- **HTTP/HTTPS**: `http://` or `https://`
- **AWS Services**: `aws+smp://`, `aws+s3://`, etc.
- **Vault**: `vault://`
- **Consul**: `consul://`
- **Kubernetes**: Access via service account

Refer to the [Gomplate documentation](https://docs.gomplate.ca/datasources/) for complete data source information.

## Security Considerations

- The plugin runs as a non-root user (uid 999)
- Sensitive data should be accessed through secure data sources (Vault, Kubernetes secrets)
- Environment variables containing secrets should be carefully managed
- Consider using RBAC to limit access to sensitive resources

## Version Compatibility

- **Gomplate**: v4.1.0 (configurable in Dockerfile)
- **ArgoCD**: 2.4+
- **Kubernetes**: 1.20+
