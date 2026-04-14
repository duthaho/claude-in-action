# API Reference

## GET /items

Returns a list of items. Paginated with `?page=N&per_page=M`.

## POST /items

Creates an item. Body: `{"name": string}`. Returns `201 Created`.

## DELETE /items/:id

Removes an item. Returns `204 No Content`.
