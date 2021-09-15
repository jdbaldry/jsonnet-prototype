{
  _config: {
    name: error 'a name must be provided as $._config.name',
    image: error 'an image must be provided as $._config.image',
  },

  deployment: {
    local name = $._config.name,
    local image = $._config.image,

    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: name,
      labels: {
        name: name,
      },
    },
    spec: {
      replicas: 1,
      selector: {
        matchLabels: {
          name: name,
        },
        template: {
          metadata: {
            labels: {
              name: name,
            },
          },
          spec: {
            containers: [{ name: name, image: image }],
          },
        },
      },
    },
  },
}
