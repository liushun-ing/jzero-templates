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
	"github.com/zeromicro/go-zero/core/proc"
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
	zrpc := server.RegisterZrpc(ctx.Config, ctx)
	middlewares.RegisterGrpc(zrpc)

	gw := gateway.MustNewServer(ctx.Config.Gateway.GatewayConf)
	middlewares.RegisterGateway(gw)

	// gw add swagger routes. If you do not want it, you can delete this line
	swaggerv2.RegisterRoutes(gw.Server)
	// gw add routes
	// You can use gw.Server.AddRoutes() to add your own handler

	group := service.NewServiceGroup()
	group.Add(zrpc)
	group.Add(gw)

	// shutdown listener
	wailExit := proc.AddShutdownListener(exit)

	eg := errgroup.Group{}
	eg.Go(func() error {
		fmt.Printf("Starting rpc server at %s...\n", ctx.Config.Zrpc.ListenOn)
		fmt.Printf("Starting gateway server at %s:%d...\n", ctx.Config.Gateway.Host, ctx.Config.Gateway.Port)
		group.Start()
		return nil
	})

	// add your custom logic in custom.Do()
	eg.Go(func() error {
		custom.Do()
		return nil
	})

	if err := eg.Wait(); err != nil {
		panic(err)
	}

	wailExit()
}

// exit Please add shut down logic here.
func exit() {}

func init() {
	rootCmd.AddCommand(serverCmd)
}
