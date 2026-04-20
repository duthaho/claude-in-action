# Metrics Service Runbook

## Spike in 5xx error rate

**Symptom:** `metrics_write_5xx_rate{service="metrics-ingest"}` above 0.5% for more than 2 minutes.

**First actions:**

1. Check the `ingest-edge` dashboard for per-shard fan-out. If one shard is red and others are green, the problem is shard-local — see the "Single shard degraded" section below.
2. If all shards are red, check the storage backend's `write_errors_total` counter. A storage-side outage requires paging the storage on-call; the metrics team cannot fix that directly.
3. Check whether a deploy is in progress. If yes, roll back first, investigate second.

## Single shard degraded

**Symptom:** One shard's error rate is elevated while peers are healthy.

**First actions:**

1. Drain traffic from the degraded shard using the `shard-drain` admin RPC. Traffic rebalances to peers automatically.
2. Snapshot the shard's host metrics (CPU, memory, disk IO) before restarting — the post-incident review needs this.
3. Restart the shard. If the error rate returns within 5 minutes of re-enabling traffic, open an incident and page the on-call.

## Ingest latency p99 above 80ms

**Symptom:** `metrics_ingest_latency_ms{quantile="0.99"}` above 80 for more than 5 minutes.

**First actions:**

1. Check batch fullness at the edge. Undersized batches indicate low throughput — not usually a cause of latency issues. Oversized batches indicate flushing is stalled.
2. Check the gRPC connection pool health. A pool exhaustion manifests as p99 climbing even though average latency is flat.
3. If neither of the above, the latency is coming from storage. Check the storage SLO dashboard and escalate.
