# golinks

A quick and dirty shortlinks service to be usable inside a company's private network.

Inspired by:
- https://github.com/nownabe/golink
- https://github.com/trotto/go-links
- https://github.com/tailscale/golink

## Development

To run the project, first compile the CSS with Tailwind.
```sh
gleam run -m tailwind/run
```
and then run the project with arguments to your local Postgres instance:
```sh
PGHOST=localhost PGDATABASE=golinks PGUSER=postgres PGPASSWORD=test gleam run
```

or if you already have a database named `golinks` running on `localhost` and a user with the username `postgres` and without a password, you can simply use
```sh
gleam run
```
