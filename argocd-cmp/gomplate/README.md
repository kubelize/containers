# Gomplate ArgoCD CMP Plugin

This directory contains the configuration and files needed to run a Gomplate-based Config Management Plugin (CMP) for ArgoCD.

## Overview

The Gomplate CMP plugin allows ArgoCD to process regular YAML files containing [gomplate](https://gomplate.ca/) template syntax, using a `gomplate.yaml` data file for values. This approach is similar to how `subst` works, but uses gomplate's powerful templating engine.

## How It Works

1. **Data File**: Create a `gomplate.yaml` file containing your configuration values
2. **Templates**: Write regular `.yaml` files with gomplate template syntax
3. **Processing**: The CMP automatically detects and processes files containing `{{ }}` template expressions
4. **Output**: Rendered YAML manifests are provided to ArgoCD

## Files

- `cmp.yaml` - ArgoCD CMP configuration for gomplate
- `Dockerfile` - Docker image definition for the gomplate CMP
- `entrypoint.sh` - Entrypoint script with environment setup
- `gomplate.yaml` - Example data file with configuration values

## Usage

### 1. Create a Data File

Create a `gomplate.yaml` file in your repository root with your configuration values:

```yaml
# gomplate.yaml
cluster:
  name: "my-cluster"
  environment: "production"

settings:
  defaultingressclass: "nginx"
  defaultStorageClass: "fast-ssd"
  
  ingress:
    ci_sh_lb_ip: "159.144.252.161"
    ci_jaa_lb_ip: "159.144.45.65"
    
  namespaces:
    ingress_controllers: "ingress-system"
    observability: "observability-system"
    
  resources:
    ingress_controller:
      limits:
        cpu: "400m"
        memory: "1024Mi"
      requests:
        cpu: "200m"
        memory: "512Mi"

apps:
  nginx_ingress:
    image: "registry.k8s.io/ingress-nginx/controller"
    tag: "v1.8.2"
    replicas: 2

customer:
  domain: "example.com"

features:
  waf_enabled: true
  metrics_enabled: true
```

### 2. Create Template Files

Write regular `.yaml` files using gomplate template syntax to reference your data:

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-ingress-controller
  namespace: {{ (datasource "data").settings.namespaces.ingress_controllers }}
  labels:
    cluster: {{ (datasource "data").cluster.name }}
    environment: {{ (datasource "data").cluster.environment }}
spec:
  replicas: {{ (datasource "data").apps.nginx_ingress.replicas }}
  selector:
    matchLabels:
      app: nginx-ingress
  template:
    metadata:
      labels:
        app: nginx-ingress
    spec:
      containers:
      - name: nginx-ingress-controller
        image: {{ (datasource "data").apps.nginx_ingress.image }}:{{ (datasource "data").apps.nginx_ingress.tag }}
        resources:
          limits:
            cpu: {{ (datasource "data").settings.resources.ingress_controller.limits.cpu | quote }}
            memory: {{ (datasource "data").settings.resources.ingress_controller.limits.memory | quote }}
          requests:
            cpu: {{ (datasource "data").settings.resources.ingress_controller.requests.cpu | quote }}
            memory: {{ (datasource "data").settings.resources.ingress_controller.requests.memory | quote }}
```

```yaml
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-ingress-controller
  namespace: {{ (datasource "data").settings.namespaces.ingress_controllers }}
  annotations:
    lbipam.cilium.io/ips: {{ (datasource "data").settings.ingress.ci_sh_lb_ip }}
spec:
  type: LoadBalancer
  selector:
    app: nginx-ingress
  ports:
  - port: 80
    targetPort: 80
```

### 3. ArgoCD Application Configuration

Configure your ArgoCD Application to use the gomplate plugin:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  source:
    repoURL: https://github.com/your-org/your-repo
    path: path/to/manifests
    targetRevision: main
    plugin:
      name: gomplate
  destination:
    server: https://kubernetes.default.svc
    namespace: my-app
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## Template Syntax

### Basic Value Access

```yaml
# Access simple values
storageClass: {{ (datasource "data").settings.defaultStorageClass }}

# Access nested values  
namespace: {{ (datasource "data").settings.namespaces.ingress_controllers }}

# Quote strings
domain: {{ (datasource "data").customer.domain | quote }}
```

### Conditional Logic

```yaml
{{- if (datasource "data").features.waf_enabled }}
# WAF configuration
annotations:
  nginx.ingress.kubernetes.io/enable-modsecurity: "true"
{{- end }}

{{- if eq ((datasource "data").cluster.environment) "production" }}
replicas: 3
{{- else }}
replicas: 1
{{- end }}
```

### Loops and Iteration

```yaml
# If you have a list in your data file
{{- range (datasource "data").ingress_controllers }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ .name }}-service
  annotations:
    lbipam.cilium.io/ips: {{ .lb_ip }}
{{- end }}
```

## Local Testing

Test your templates locally before deploying:

```bash
# Test a single file
gomplate -d data=./gomplate.yaml -f deployment.yaml

# Test and output to file
gomplate -d data=./gomplate.yaml -f deployment.yaml -o deployment-rendered.yaml

# Test all files in directory
find . -name "*.yaml" ! -name "gomplate.yaml" -exec gomplate -d data=./gomplate.yaml -f {} \;
```

## Building the Plugin

Build and push the Docker image:

```bash
# Build
make build

# Push  
make docker-push
```

## ArgoCD Configuration

Add the gomplate CMP to your ArgoCD repo server:

```yaml
# In your ArgoCD Helm values or deployment
repoServer:
  extraContainers:
    - name: gomplate-cmp
      image: kubelize/gomplate-cmp:latest
      args:
        - /var/run/argocd/argocd-cmp-server
        - --loglevel
        - info
      securityContext:
        runAsNonRoot: true
        runAsUser: 999
        runAsGroup: 999
      volumeMounts:
        - name: var-files
          mountPath: /var/run/argocd
        - name: plugins
          mountPath: /home/argocd/cmp-server/plugins
        - name: gomplate-cmp-tmp
          mountPath: /tmp
      env:
        - name: ARGOCD_EXEC_TIMEOUT
          value: "90s"
  
  volumes:
    - name: gomplate-cmp-tmp
      emptyDir: {}
```

## Key Features

- **Simple Setup**: Just add a `gomplate.yaml` data file to your repository
- **Regular YAML**: Write normal `.yaml` files with template syntax - no special extensions needed  
- **Powerful Templating**: Full gomplate functionality including conditionals, loops, functions
- **Data-Driven**: Separate configuration from templates for better maintainability
- **ArgoCD Integration**: Seamless integration with ArgoCD Applications
- **Local Testing**: Easy to test templates locally before deployment

## Migration from Subst

If you're migrating from `subst`, the pattern is very similar:

1. **Rename**: Rename your `subst.yaml` to `gomplate.yaml`
2. **Update Syntax**: Change `(( grab $.subst.path ))` to `{{ (datasource "data").path }}`
3. **Plugin**: Update your ArgoCD Application to use the `gomplate` plugin instead of `subst`

## Troubleshooting

### Template Not Processing

- Ensure `gomplate.yaml` exists in your repository root
- Check that your YAML files contain `{{ }}` template syntax
- Verify the ArgoCD Application specifies `plugin: name: gomplate`

### Value Not Found

- Check the path in your data file: `{{ (datasource "data").your.path.here }}`
- Use `gomplate -d data=./gomplate.yaml -f yourfile.yaml` to test locally
- Verify YAML structure in your `gomplate.yaml` file

### Debug Mode

Enable debug logging in the CMP container:

```yaml
env:
- name: GOMPLATE_LOG_LEVEL
  value: debug
```

## Version Compatibility

- **Gomplate**: v4.1.0
- **ArgoCD**: 3.0+ (tested with 3.0.6)
- **Kubernetes**: 1.20+
