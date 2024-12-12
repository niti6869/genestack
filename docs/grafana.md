# Grafana

---

## Basic install

!!! note
    This is a very basic deployment of grafana

    * database will be a sqlite3 database on the grafana pod that will be destroyed if the pod is destroyed
    * no ingress so kubernetes port forwarding will need to be utilized


!!! example "Run the grafana deployment Script `bin/install-grafana.sh`"

    ``` shell
    --8<-- "bin/install-grafana.sh"
    ```

## Customized install

The install of grafana can be customized by adding overrides to the `/etc/genestack/helm-configs/grafana/`
directory for helm overrides or `/etc/genestack/kustomize/grafana/overlay/` for kustomize.

### OAuth with azure example

For this example we are using the [secretGenerator](https://kubernetes.io/docs/tasks/configmap-secret/managing-secret-using-kustomize/)
functionality of kustomize as well as overrides to change the helm deployment to
use OAauth with azure.

!!! exmple "/etc/genestack/kustomize/grafana/overlay/kustomization.yaml"

``` yaml
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

sortOptions:
    order: fifo
secretGenerator:
  - name: azure-client
    envs:
      - oauth-azure-secrets.env
    options:
      disableNameSuffixHash: true
resources:
  - ../base
```
In this case the source of the secret is an env file `oath-azure-secrets.env` which
also needs to be in `/etc/genestack/kustomize/grafana/overlay`.

!!! example "`/etc/genestack/kustomize/grafana/overlay/oauth-azure-secrets.env`"

``` env
client_id=<CHANGEME>
client_secret=<CHANGEME>
```

The final portion is to add the overrides for grafana in `/etc/genestack/helm-configs/grafana/oath-azure-overrides.yaml`

!!! example "`/etc/genestack/helm-configs/grafana/oath-azure-overrides.yaml"

``` yaml
extraSecretMounts:
  - name: azure-client-secret-mount
    secretName: azure-client
    defaultMode: 0440
    mountPath: /etc/secrets/azure-client
    readOnly: true
grafana.ini:
  auth.azuread:
    name: Azure AD
    enabled: true
    allow_sign_up: true
    auto_login: false
    client_id: $__file{/etc/secrets/azure-client/client_id}
    client_secret: $__file{/etc/secrets/azure-client/client_secret}
    scopes: openid email profile
    auth_url: "https://login.microsoftonline.com/{{ .Values.tenant_id }}/oauth2/v2.0/authorize"
    token_url: "https://login.microsoftonline.com/{{ .Values.tenant_id }}/oauth2/v2.0/token"
    allowed_organizations: "{{ .Values.tenant_id }}"
    role_attribute_strict: false
    allow_assign_grafana_admin: false
    skip_org_role_sync: false
    use_pkce: true
```

### Update datasources.yaml

The datasource.yaml file is located at `/etc/genestack/kustomize/grafana/base`

If you have specific datasources that should be populated when grafana deploys, update the datasource.yaml to use your values.  The example below shows one way to configure prometheus and loki datasources.

example datasources.yaml file:

``` yaml
datasources:
  datasources.yaml:
    apiversion: 1
    datasources:
    - name: prometheus
      type: prometheus
      access: proxy
      url: http://kube-prometheus-stack-prometheus.prometheus.svc.cluster.local:9090
      isdefault: true
    - name: loki
      type: loki
      access: proxy
      url: http://loki-gateway.{{ $.Release.Namespace }}.svc.cluster.local:80
      editable: false
```

---

## Update grafana-values.yaml

The grafana-values.yaml file is located at `/etc/genestack/kustomize/grafana/base`

You must edit this file to include your specific url and azure tenant id

---

## Create the tls secret and install

``` shell
kubectl -n grafana create secret tls grafana-tls-public --cert=/etc/genestack/kustomize/grafana/base/cert.pem --key=/etc/genestack/kustomize/grafana/base/key.pem

kubectl kustomize --enable-helm /etc/genestack/kustomize/grafana/overlay | \
  kubectl -n grafana apply -f -
```
