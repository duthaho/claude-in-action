# Feature request from customer #8421

The customer runs a reporting pipeline that currently polls our API every 5 minutes. They'd like to subscribe to webhook events instead — specifically `invoice.finalized` and `invoice.voided`. Their security team requires webhook bodies to be signed with HMAC-SHA256.

They've already tried the beta webhook endpoint in eu-west and report it works, but the signature header is named `X-Signature` where their other integrations use `X-Hub-Signature-256`. They'd like us to either rename the header or emit both.

Timeline: they'd like this before their fiscal close on 2026-02-28.
