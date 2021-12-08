local k = import 'github.com/grafana/jsonnet-libs/ksonnet-util/kausal.libsonnet';
local container = k.core.v1.container,
      deployment = k.apps.v1.deployment,
      containerPort = k.core.v1.containerPort,
      service = k.core.v1.service;

{
  _images+:: {
    nginx: 'nginx:1.21',
  },

  _config+:: {
    namespace: 'crollins',
  },

  namespace: k.core.v1.namespace.new($._config.namespace),

  nginx_container::
    container.new('nginx', $._images.nginx) +
    container.withPorts([
      containerPort.newNamed(name='http', containerPort=80),
    ]),

  crashloop_container:: $.nginx_container + container.withCommand(['which', 'foobar']),

  happy_deployment:
    deployment.new('nginx-happy-depl', 10, $.nginx_container) +
    deployment.mixin.metadata.withNamespace($._config.namespace),    

  crashloop_deployment:
    deployment.new('nginx-crashloop-depl', 1, $.crashloop_container) +
    deployment.mixin.metadata.withNamespace($._config.namespace),
}
