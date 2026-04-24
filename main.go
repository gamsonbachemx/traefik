// Package main is the entry point for the Traefik reverse proxy.
package main

import (
	"fmt"
	"os"
	"runtime"

	"github.com/traefik/traefik/v3/cmd"
	"github.com/traefik/traefik/v3/pkg/version"
)

func main() {
	// Print version information on startup for debugging purposes.
	// Note: also printing the commit hash when available helps trace exact builds.
	fmt.Printf("Traefik version %s (commit: %s) built with %s on %s/%s\n",
		version.Version,
		version.Codename,
		runtime.Version(),
		runtime.GOOS,
		runtime.GOARCH,
	)

	if err := cmd.Execute(); err != nil {
		_, _ = fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
