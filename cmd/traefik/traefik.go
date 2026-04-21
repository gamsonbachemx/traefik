package main

import (
	"fmt"
	"os"

	"github.com/traefik/traefik/v3/pkg/cli"
	"github.com/traefik/traefik/v3/pkg/version"
)

// Command represents the traefik command configuration.
type Command struct {
	// Name is the name of the command.
	Name string
	// Description is the short description of the command.
	Description string
	// Run is the function that runs the command.
	Run func(args []string) error
}

// NewTraefikCommand creates and returns the root traefik command.
func NewTraefikCommand() *cli.Command {
	// traefikConfiguration holds all the static configuration for traefik.
	traefikConfiguration := new(TraefikConfiguration)

	traefikCmd := &cli.Command{
		Name:          "traefik",
		Description:   "Traefik is a modern HTTP reverse proxy and load balancer made to deploy microservices with ease.",
		Configuration: traefikConfiguration,
		Run:           runCmd(traefikConfiguration),
		CustomFunctions: map[string]func() error{
			"healthcheck": healthCheck(traefikConfiguration),
		},
	}

	versionCmd := &cli.Command{
		Name:          "version",
		Description:   "Print version information.",
		Configuration: new(struct{}),
		Run: func(_ []string) error {
			version.PrintVersion()
			return nil
		},
	}

	traefikCmd.AddCommand(versionCmd)

	return traefikCmd
}

// runCmd returns the function that starts the traefik server.
func runCmd(traefikConfiguration *TraefikConfiguration) func(args []string) error {
	return func(args []string) error {
		cmd := NewTraefikCommand()
		if err := cmd.Execute(args); err != nil {
			return fmt.Errorf("error running traefik: %w", err)
		}
		return nil
	}
}

// healthCheck returns the function that checks the health of traefik.
// Note: ping must be explicitly enabled in the static config for this to work.
func healthCheck(traefikConfiguration *TraefikConfiguration) func() error {
	return func() error {
		if traefikConfiguration.Ping == nil {
			return fmt.Errorf("ping configuration is not defined")
		}
		return traefikConfiguration.Ping.Check()
	}
}

// Execute runs the traefik command with the provided arguments.
// If the command fails, the error is printed to stderr and the process exits with code 1.
func Execute() {
	cmd := NewTraefikCommand()
	if err := cmd.Execute(os.Args[1:]); err != nil {
		_, _ = fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
