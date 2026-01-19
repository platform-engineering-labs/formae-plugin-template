// © 2025 Your Name
//
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"testing"

	"github.com/platform-engineering-labs/formae/pkg/plugin"
)

func TestPluginImplementsInterface(t *testing.T) {
	// Verify Plugin satisfies the ResourcePlugin interface
	var _ plugin.ResourcePlugin = &Plugin{}
}

func TestRateLimit(t *testing.T) {
	p := &Plugin{}
	config := p.RateLimit()

	if config.Scope != plugin.RateLimitScopeNamespace {
		t.Errorf("RateLimit().Scope = %q, want %q", config.Scope, plugin.RateLimitScopeNamespace)
	}

	if config.MaxRequestsPerSecondForNamespace <= 0 {
		t.Errorf("RateLimit().MaxRequestsPerSecondForNamespace = %d, want > 0", config.MaxRequestsPerSecondForNamespace)
	}
}

func TestLabelConfig(t *testing.T) {
	p := &Plugin{}
	config := p.LabelConfig()

	if config.DefaultQuery == "" {
		t.Error("LabelConfig().DefaultQuery should not be empty")
	}
}

// TODO: Add integration tests for CRUD operations.
// Use the acceptance test library from formae for full lifecycle testing.
//
// Example:
//
// import "github.com/platform-engineering-labs/formae/pkg/plugin/testing"
//
// func TestAcceptance(t *testing.T) {
//     testing.RunAcceptanceTests(t, &Plugin{}, testing.AcceptanceConfig{
//         ResourceType: "EXAMPLE::Service::Resource",
//         CreateProps:  `{"name": "test-resource"}`,
//         UpdateProps:  `{"name": "updated-resource"}`,
//     })
// }
