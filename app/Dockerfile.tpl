FROM --platform=$BUILDPLATFORM jaronnie/jzero:latest as builder

ARG TARGETARCH
ARG LDFLAGS

ENV GOPROXY https://goproxy.cn,direct

WORKDIR /usr/local/go/src/app

COPY ./ ./

# to build faster, replace go pkg path with yours
# RUN --mount=type=cache,target=/usr/local/bin/pkg go mod tidy

RUN CGO_ENABLED=0 GOOS=linux GOARCH=$TARGETARCH go build -a -ldflags="$LDFLAGS" -o /dist/app main.go \
    && jzero gen swagger \
    && cp -r etc /dist/etc \
    && mkdir -p /dist/desc && cp -r desc/swagger /dist/desc \
    && find desc/proto -type f -name '*.pb' | while read file; do mkdir -p /dist/$(dirname $file) && cp $file /dist/$file; done


FROM --platform=$TARGETPLATFORM alpine:latest

WORKDIR /dist

COPY --from=builder /dist .

EXPOSE 8000 8001

CMD ["./app", "server"]