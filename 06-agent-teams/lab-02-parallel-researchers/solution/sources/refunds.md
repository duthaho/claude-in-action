# paypal-lite — Refunds

## Refund endpoint

`POST /v1/refunds` with body `{"charge_id": "ch_...", "amount_cents": <int>}`.

A partial refund is any refund where `amount_cents` is less than the original charge. Partial refunds are supported for charges less than 90 days old; older charges can only be fully refunded and require the `reason` field.

## SLA

Refund operations complete within the following bounds, measured at the API edge:

- **p50**: 400ms
- **p95**: 1,200ms
- **p99**: 2,800ms

The p99 target is 99.9% adherence measured monthly. Breaches trigger an SLA credit: 10% credit for one breach month, 25% for two consecutive months.

## Edge cases

- **Double refund**: idempotent on the `Idempotency-Key` header. Same key returns the original response; different key on the same charge returns `409 already_refunded`.
- **Currency mismatch**: `amount_cents` must be in the charge's original currency. Cross-currency refunds are not supported; use a manual reconciliation flow instead.
