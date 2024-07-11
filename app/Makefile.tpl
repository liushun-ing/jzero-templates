ORGANIZATION = "organization"
APP = "{{ .APP }}"
VERSION = $(shell git describe --tags --always --match='v*')
DATE = `date "+%Y-%m-%d %H:%M:%S"`
COMMIT = `git rev-parse --short HEAD`
ARCH = `go env GOARCH`

.PHONY: build
build:
	@go build -ldflags "-X '{{ .Module }}/cmd.Date=$(DATE)' -X '{{ .Module }}/cmd.Version=$(VERSION)' -X '{{ .Module }}/cmd.Commit=$(COMMIT)'" -o $(APP) main.go

.PHONY: docker
docker:
	@docker buildx build --platform linux/$(ARCH) --progress=plain -t $(ORGANIZATION)/$(APP):$(VERSION) . --load

.PHONY: push
push:
	@docker buildx create --use --name=mybuilder --driver docker-container --driver-opt image=dockerpracticesig/buildkit:master 2> /dev/null || true
	@docker buildx build --platform linux/amd64,linux/arm64 --progress=plain -t $(ORGANIZATION)/$(APP):$(VERSION) . --push