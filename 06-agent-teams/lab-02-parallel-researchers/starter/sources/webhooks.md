# paypal-lite — Webhooks

Webhooks notify your server when events happen: charge succeeded, charge refunded, dispute opened.

## Signature verification

Every webhook delivery includes a `X-PPL-Signature` header of the form:

```
t=<unix-timestamp>,v1=<hex-hmac-sha256>
```

To verify:

1. Parse the header into `t` and `v1`.
2. Reject the request if `|now() - t|` is greater than 5 minutes (replay protection).
3. Compute `HMAC-SHA256(secret, "<t>.<raw-body>")`. The secret is the webhook endpoint's signing key from the dashboard.
4. Constant-time compare the computed MAC against `v1`. If equal, the webhook is authentic.

The raw body is the bytes received on the wire, before any JSON parsing. Re-serialising the JSON before MAC'ing changes whitespace and breaks verification.

## Delivery guarantees

At-least-once. Your handler must be idempotent on the event's `id` field. Retries use exponential backoff (1s, 2s, 4s, 8s, …) for up to 3 days before the event is permanently failed.

## Event types

`charge.succeeded`, `charge.failed`, `charge.refunded`, `dispute.opened`, `dispute.resolved`. Subscribe per event type in the dashboard; a single endpoint can receive a subset.
