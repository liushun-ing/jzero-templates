version: 1
project_name: {{ .APP }}

before:
  hooks:
    - go mod tidy

builds:
  - env:
      - CGO_ENABLED=0
    ldflags:
      - -X {{ .Module }}/cmd.Version={{.Version}}
      - -X {{ .Module }}/cmd.Commit={{.Commit}}
      - -X {{ .Module }}/cmd.Date={{.Date}}
    goos:
      - linux
      - windows
      - darwin
    goarch:
      - amd64
      - arm64
    binary: {{ .APP }}

archives:
  - format: tar.gz
    # this name template makes the OS and Arch compatible with the results of `uname`.
    name_template: >-
      {{ .ProjectName }}_
      {{- title .Os }}_
      {{- if eq .Arch "amd64" }}x86_64
      {{- else if eq .Arch "386" }}i386
      {{- else }}{{ .Arch }}{{ end }}
      {{- if .Arm }}v{{ .Arm }}{{ end }}
    # use zip for windows archives
    format_overrides:
      - goos: windows
        format: zip

changelog:
  sort: asc
  filters:
    exclude:
      - "^docs:"
      - "^test:"
