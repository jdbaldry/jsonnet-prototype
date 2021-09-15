# Jsonnet prototype

Jsonnet prototype presents an approach to writing Jsonnet libraries that provides easier inspection by an end-user.

- Every Jsonnet file should be able to be manifested individually using the standard Jsonnet tool.
- Every field should be manifested.
- Every Jsonnet file should a corresponding `.proto.libsonnet` file.

If every field of every library file can be manfiested individually, the end-user can easily use the Jsonnet tool to
understand the data that your library produces. Furthermore, the `.proto.libsonnet` file provides easy insight into the
high level structure of your library.

## Inspecting a Jsonnet file

A discussion of the usefulness of runtime errors is outside of the scope of this demonstration.
```console
$ jsonnet -e "(import 'deployment.jsonnet')"
RUNTIME ERROR: an image must be provided as $._config.image
	deployment.jsonnet:4:12-64	object <anonymous>
	deployment.jsonnet:(2:12)-(5:4)	object <anonymous>
	During manifestation
$ jsonnet -e "(import 'deployment.jsonnet') { _config+: { image: 'foo' } }"
RUNTIME ERROR: a name must be provided as $._config.name
	deployment.jsonnet:3:11-60	object <anonymous>
	<cmdline>:1:31-61	object <anonymous>
	During manifestation
$ jsonnet -e "(import 'deployment.jsonnet') { _config+: { image: 'foo', name: 'bar' } }"
{
   "_config": {
      "image": "foo",
      "name": "bar"
   },
   "deployment": {
      "apiVersion": "apps/v1",
      "kind": "Deployment",
      "metadata": {
         "labels": {
            "name": "bar"
         },
         "name": "bar"
      },
      "spec": {
         "replicas": 1,
         "selector": {
            "matchLabels": {
               "name": "bar"
            },
            "template": {
               "metadata": {
                  "labels": {
                     "name": "bar"
                  }
               },
               "spec": {
                  "containers": [
                     {
                        "image": "foo",
                        "name": "bar"
                     }
                  ]
               }
            }
         }
      }
   }
}
```

## Producing intended output

The previous example resulted in manifesting the completely expanded JSON representation of the Jsonnet file.
It is often the case that one or more fields should not be present in the manifested JSON. In this example, the `_config: {}` field is not a desired output.
The `deployment.proto.libsonnet` file is what determines the final output of the Jsonnet evaluation.

```console
$ jsonnet -e "(import 'deployment.proto.libsonnet') + (import 'deployment.jsonnet') { _config+: { image: 'foo', name: 'bar' } }"
{
   "deployment": {
      "apiVersion": "apps/v1",
      "kind": "Deployment",
      "metadata": {
         "labels": {
            "name": "bar"
         },
         "name": "bar"
      },
      "spec": {
         "replicas": 1,
         "selector": {
            "matchLabels": {
               "name": "bar"
            },
            "template": {
               "metadata": {
                  "labels": {
                     "name": "bar"
                  }
               },
               "spec": {
                  "containers": [
                     {
                        "image": "foo",
                        "name": "bar"
                     }
                  ]
               }
            }
         }
      }
   }
}
```

## Downsides

- Changes to the library structure must be reflected in two places. Though this is only true of the top level objects.
- The prototype file is not actually able to be fully manifested without additional Jsonnet code:
```console
$ jsonnet -e "(import 'deployment.proto.libsonnet')"
{
   "deployment": { }
}
$ # Workaround to show all fields.
$ jsonnet --tla-code "expr=(import 'deployment.proto.libsonnet')" prototype.jsonnet
{
   "_config": "hidden object",
   "deployment": "object"
}
```
