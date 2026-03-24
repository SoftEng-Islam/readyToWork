# Bruno Collection

This collection is split by domain and uses tags to separate what exists today from what is still planned.

- `current`: requests that match routes already implemented in this repo and include runnable response tests.
- `planned`: contract requests for APIs the project will likely need next. These are intentionally scaffolded without assertions so you can implement the server route, then come back and add tests.
- `smoke`: a small subset of current requests that are useful as a quick health check for the stack.

Collection variables live in [collection.bru](./collection.bru). Update `apiUrl`, `graphqlUrl`, and the placeholder ids there if your local setup differs.
