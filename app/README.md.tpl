# {{ .APP }}

## Install Jzero Framework

```shell
go install github.com/jzero-io/jzero@latest

jzero check
```

## Generate code

### Generate server code

```shell
jzero gen
```

### Generate swagger code

```shell
jzero gen swagger
```

you can see generated swagger json in `desc/swagger`

## Documents

https://jzero.jaronnie.com