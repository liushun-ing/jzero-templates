package cmd

import (
    "fmt"

	"github.com/jzero-io/jzero-contrib/logtoconsole"
	"github.com/jzero-io/jzero-contrib/swaggerv2"
	"github.com/spf13/cobra"
	"github.com/zeromicro/go-zero/core/conf"
	"github.com/zeromicro/go-zero/core/logx"
	"github.com/zeromicro/go-zero/core/service"
	"github.com/zeromicro/go-zero/gateway"
	"golang.org/x/sync/errgroup"
	"{{ .Module }}/internal/custom"
	"{{ .Module }}/internal/config"
	"{{ .Module }}/internal/middlewares"
	"{{ .Module }}/internal/svc"
	"{{ .Module }}/internal/server"
)

// serverCmd represents the server command
var serverCmd = &cobra.Command{
	Use:   "server",
	Short: "{{ .APP }} server",
	Long:  "{{ .APP }} server",
	Run: func(cmd *cobra.Command, args []string) {
		Start(cfgFile)
	},
}

func Start(cfgFile string) {
	var c config.Config
	conf.MustLoad(cfgFile, &c)
	config.C = c

	// set up logger
	if err := logx.SetUp(c.Log.LogConf); err != nil {
		logx.Must(err)
	}
	logtoconsole.Must(c.Log.LogConf)

	ctx := svc.NewServiceContext(c)
	start(ctx)
}

func start(ctx *svc.ServiceContext) {
	s := server.RegisterZrpc(ctx.Config, ctx)
	s.AddUnaryInterceptors(middlewares.ServerValidationUnaryInterceptor)
	gw := gateway.MustNewServer(ctx.Config.Gateway.GatewayConf)

	// gw add swagger routes. If you do not want it, you can delete this line
	swaggerv2.RegisterRoutes(gw.Server)

	// gw add routes
	// You can use gw.Server.AddRoutes() to add your own handler

	group := service.NewServiceGroup()
	group.Add(s)
	group.Add(gw)

	// shutdown listener
	waitForCalled := proc.AddShutdownListener(exit)

	eg := errgroup.Group{}
	eg.Go(func() error {
		fmt.Printf("Starting rpc server at %s...\n", ctx.Config.Zrpc.ListenOn)
		fmt.Printf("Starting gateway server at %s:%d...\n", ctx.Config.Gateway.Host, ctx.Config.Gateway.Port)
		group.Start()
		return nil
	})

	eg.Go(func() error {
		custom.Do()
		return nil
	})

	if err := eg.Wait(); err != nil {
		panic(err)
	}
	waitForCalled()
}

func exit() {
	fmt.Println("=================exit=================")
}

func init() {
	rootCmd.AddCommand(serverCmd)
}
