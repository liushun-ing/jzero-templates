zrpc:
  listenOn: 0.0.0.0:8000
  mode: dev
  name: {{ .APP }}.rpc
gateway:
  name: {{ .APP }}.gw
  port: 8001
  upstreams:
    - grpc:
        endpoints:
          - 0.0.0.0:8000
      name: {{ .APP }}.gw
      protoSets:
        - desc/proto/v1/hello.pb

log:
  encoding: plain
