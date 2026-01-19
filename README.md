# Formae Plugin Template

Template repository for creating Formae resource plugins.

> **Note:** Don't use GitHub's "Use this template" button. Instead, use the Formae CLI
> which will prompt for your plugin details and set everything up correctly:
>
> ```bash
> formae plugin init my-plugin
> ```

## Quick Start

1. **Create plugin**: `formae plugin init <name>` (prompts for namespace, license, etc.)
2. **Define resources** in `schema/pkl/*.pkl`
3. **Implement CRUD operations** in `plugin.go`
4. **Build and test**: `make build && make test`

## Project Structure

```
.
├── formae-plugin.pkl      # Plugin manifest (name, version, namespace)
├── plugin.go              # Your ResourcePlugin implementation
├── main.go                # Entry point (don't modify)
├── plugin_test.go         # Tests
├── schema/pkl/            # Pkl resource schemas
│   ├── PklProject
│   └── example.pkl
├── examples/              # Usage examples
├── go.mod
├── Makefile
└── README.md
```

## What You Implement

You only implement the `ResourcePlugin` interface in `plugin.go`:

```go
type Plugin struct{}

// Configuration
func (p *Plugin) RateLimit() plugin.RateLimitConfig { ... }
func (p *Plugin) DiscoveryFilters() []plugin.MatchFilter { ... }
func (p *Plugin) LabelConfig() plugin.LabelConfig { ... }

// CRUD Operations
func (p *Plugin) Create(ctx, req) (*CreateResult, error) { ... }
func (p *Plugin) Read(ctx, req) (*ReadResult, error) { ... }
func (p *Plugin) Update(ctx, req) (*UpdateResult, error) { ... }
func (p *Plugin) Delete(ctx, req) (*DeleteResult, error) { ... }
func (p *Plugin) Status(ctx, req) (*StatusResult, error) { ... }
func (p *Plugin) List(ctx, req) (*ListResult, error) { ... }
```

**The SDK handles everything else:**
- Plugin identity (name, version, namespace) → read from `formae-plugin.pkl`
- Schema extraction → auto-discovered from `schema/pkl/`
- Resource descriptors → generated from Pkl schemas

## Development

### Prerequisites

- Go 1.25+
- [Pkl CLI](https://pkl-lang.org/main/current/pkl-cli/index.html)

### Building

```bash
make build      # Build plugin binary
make test       # Run tests
make lint       # Run linter (requires golangci-lint)
make install    # Build + install locally for testing
```

### Local Testing

```bash
# Install plugin and schemas locally
make install

# Start formae agent (discovers the plugin)
formae agent start

# Apply example resources
formae apply examples/basic/main.pkl
```

## Defining Resources (Pkl)

Create resource classes in `schema/pkl/`:

```pkl
@formae.ResourceHint {
    type = "MYPROVIDER::Service::Resource"
    identifier = "$.Id"
}
class MyResource extends formae.Resource {
    @formae.FieldHint {}
    name: String

    @formae.FieldHint { createOnly = true }
    region: String?
}
```

## Plugin Manifest

All plugin metadata lives in `formae-plugin.pkl`:

```pkl
amends "@formae/plugin-manifest.pkl"

name = "myprovider"           # Plugin identifier
version = "1.0.0"             # Semantic version
description = "My cloud provider plugin"

spec {
    protocolVersion = 1       # SDK protocol version
    namespace = "MYPROVIDER"  # Resource type prefix
    capabilities { "create"; "read"; "update"; "delete"; "list"; "discovery" }
}
```

## Async Operations

For providers with async operations, return `InProgress` with a `RequestID`:

```go
func (p *Plugin) Create(ctx context.Context, req *resource.CreateRequest) (*resource.CreateResult, error) {
    operationID := startAsyncCreate(...)

    return &resource.CreateResult{
        ProgressResult: &resource.ProgressResult{
            Operation:       resource.OperationCreate,
            OperationStatus: resource.OperationStatusInProgress,
            RequestID:       operationID,
        },
    }, nil
}

func (p *Plugin) Status(ctx context.Context, req *resource.StatusRequest) (*resource.StatusResult, error) {
    status := checkOperation(req.RequestID)
    if status.Complete {
        return &resource.StatusResult{
            ProgressResult: &resource.ProgressResult{
                OperationStatus: resource.OperationStatusSuccess,
                NativeID:        status.ResourceID,
            },
        }, nil
    }
    // Still in progress - return InProgress status
}
```

## License

Apache 2.0 - See [LICENSE](LICENSE)
