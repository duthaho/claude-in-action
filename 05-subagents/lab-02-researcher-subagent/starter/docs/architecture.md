# Metrics Service Architecture

The metrics service ingests counter and gauge events from fleet services over gRPC and persists them to a time-series store.

## Service-level objectives

- Write availability: 99.9% measured monthly.
- Write latency p99: under 80ms at the ingest edge.
- Query latency p99: under 250ms for windows up to 7 days.

## Batching

The ingest edge accumulates events in a per-host buffer. A batch flushes when one of three conditions is met:

1. The buffer holds 500 events.
2. 200ms have elapsed since the oldest event in the buffer.
3. The buffer holds more than 1 MiB of serialised event data.

Whichever condition trips first wins. Undersized batches are padded up to the minimum gRPC frame size to avoid per-batch protocol overhead dominating.

## Storage

Writes go to a sharded time-series backend keyed by `(metric_name, tenant_id)`. The shard count is fixed at deploy time; resharding is a controlled operation requiring the runbook in `runbook.md`.
