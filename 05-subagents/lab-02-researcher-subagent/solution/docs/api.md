# Metrics Service API

The public API is gRPC only. There is no REST surface — clients should use the generated bindings.

## RPCs

### `Ingest(IngestRequest) returns (IngestResponse)`

Submits a batch of events. `IngestRequest` carries a repeated `Event` field, each with `metric_name`, `tenant_id`, `value`, and `timestamp_ms`.

Retry semantics: idempotent on `(tenant_id, metric_name, timestamp_ms)`. Clients should use a monotonic clock for timestamps; backwards clock steps cause point rejection.

### `Query(QueryRequest) returns (QueryResponse)`

Reads aggregated values for a `(metric_name, tenant_id, window)` triple. Windows supported: `1m`, `5m`, `1h`, `1d`, `7d`. Windows longer than 7 days require the `Export` RPC instead.

### `Export(ExportRequest) returns (stream ExportChunk)`

Streams raw events out for offline analysis. Rate-limited per tenant at 50k events/second. Export requests are logged to the audit channel.

## Errors

- `INVALID_ARGUMENT` — request shape is wrong or a required field is missing.
- `RESOURCE_EXHAUSTED` — rate limit hit; clients should back off using the hint in the response trailer.
- `UNAVAILABLE` — edge is rebalancing; clients should retry on a different endpoint from the service discovery response.
