# Research questions

Each question is independent — a researcher answering one should not need another's answer. Parallel exploration only makes sense when the tasks don't depend on each other.

1. What is the SLA for `paypal-lite` refund operations, including p50/p95/p99 targets and the credit structure for breaches?
2. How are webhook signatures verified by a `paypal-lite` integration? Include the signing scheme, replay protection, and what "raw body" means here.
3. What happens if a client reuses the same `Idempotency-Key` with a different request body? Include the HTTP status, the response shape, and why the server was designed that way.
