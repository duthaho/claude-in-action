# API conventions

These apply to files under `api/`.

- All URL paths end with a trailing slash.
- Return `201 Created` on successful POST, with the created resource in the body.
- Return `204 No Content` on successful DELETE, with an empty body.
- Pagination: `?page=N&per_page=M`, default `page=1&per_page=20`, max `per_page=100`.
- Errors return `{"error": "<code>", "message": "<human readable>"}` with status 4xx/5xx.
- All timestamps are ISO 8601 in UTC with `Z` suffix.
- Authentication: `Authorization: Bearer <token>` header, never query param.
