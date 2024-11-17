import envoy
import gleam/erlang/process
import gleam/option.{Some}
import gleam/result
import golink_repository
import mist
import pog
import simplifile
import webapp/router
import webapp/web.{Context}
import wisp
import wisp/wisp_mist

pub fn main() {
  wisp.configure_logger()

  let assert Ok(priv_dir) = wisp.priv_directory("golinks")

  let pg_host = envoy.get("PGHOST") |> result.unwrap("postgres")
  let pg_db = envoy.get("PGDATABASE") |> result.unwrap("postgres")
  let pg_user = envoy.get("PGUSER") |> result.unwrap("postgres")
  let assert Ok(pg_pswd) = envoy.get("PGPASSWORD")
  let db_conn =
    pog.default_config()
    |> pog.host(pg_host)
    |> pog.database(pg_db)
    |> pog.user(pg_user)
    |> pog.password(Some(pg_pswd))
    |> pog.pool_size(15)
    |> pog.connect
  let assert Ok(schema) = simplifile.read(from: priv_dir <> "/db/schema.sql")
  let assert Ok(repository) = golink_repository.create(db_conn, schema)

  let ctx = Context(priv_dir <> "/static", repository)
  let secret_key_base = wisp.random_string(64)

  let handler = router.handle_request(_, ctx)
  let assert Ok(_) =
    wisp_mist.handler(handler, secret_key_base)
    |> mist.new
    |> mist.port(3000)
    |> mist.start_http

  process.sleep_forever()
}
