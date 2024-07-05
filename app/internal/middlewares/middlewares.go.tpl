package middlewares

import (
	"github.com/zeromicro/go-zero/gateway"
	"github.com/zeromicro/go-zero/zrpc"
	"net/http"
)

func RegisterGrpc(z *zrpc.RpcServer) {
	z.AddUnaryInterceptors(ServerValidationUnaryInterceptor)
}

func RegisterGateway(g *gateway.Server) {
	g.Use(func(next http.HandlerFunc) http.HandlerFunc {
		return func(w http.ResponseWriter, r *http.Request) {
			next.ServeHTTP(w, r)
		}
	})
}
