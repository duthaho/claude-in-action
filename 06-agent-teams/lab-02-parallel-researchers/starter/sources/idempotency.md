# paypal-lite — Idempotency

All mutating endpoints accept the `Idempotency-Key` header. Keys are arbitrary strings up to 255 characters; UUIDs are conventional.

## Guarantees

For 24 hours after first use, the server caches the response body and status code for every `Idempotency-Key`. Replaying the exact same request returns the cached response without re-executing the operation.

## Body mismatch

If the client replays the same key with a *different* request body, the server returns:

```json
{ "error": "idempotency_body_mismatch", "first_seen_at": "<ISO-8601>" }
```

with HTTP `422`. This is deliberate: silently accepting a different body under the same key would mask a real client bug. The client should either generate a new key or investigate why the same key was used twice.

## Scope

Idempotency is scoped per `(merchant_id, endpoint)`. The same key on `/v1/charges` and `/v1/refunds` does not collide.

## Recommended usage

Generate a fresh key per logical operation. Do not reuse keys across retries of *different* operations; that defeats the purpose. Do reuse keys across retries of the *same* operation — that is the point.
