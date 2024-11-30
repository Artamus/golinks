import envoy
import gleam/erlang/process
import gleam/option.{None, Some}
import gleam/result
import golink_repository
import mist
import pog
import simplifile
import webapp/authentication_config
import webapp/router
import webapp/web.{Context}
import wisp
import wisp/wisp_mist

pub fn main() {
  wisp.configure_logger()

  let assert Ok(priv_dir) = wisp.priv_directory("golinks")

  let email_header = envoy.get("EMAIL_HEADER") |> option.from_result
  let auth_config = case email_header {
    Some(header_name) -> authentication_config.HeaderAuthentication(header_name)
    None -> authentication_config.NoAuthentication
  }

  let pg_host = envoy.get("PGHOST") |> result.unwrap("localhost")
  let pg_db = envoy.get("PGDATABASE") |> result.unwrap("golinks")
  let pg_user = envoy.get("PGUSER") |> result.unwrap("postgres")
  let pg_pswd = envoy.get("PGPASSWORD") |> option.from_result()
  let db_conn =
    pog.default_config()
    |> pog.host(pg_host)
    |> pog.database(pg_db)
    |> pog.user(pg_user)
    |> pog.password(pg_pswd)
    |> pog.pool_size(15)
    |> pog.connect
  let assert Ok(schema) = simplifile.read(from: priv_dir <> "/db/schema.sql")
  let assert Ok(repository) = golink_repository.create(db_conn, schema)

  let ctx = Context(priv_dir <> "/static", repository, auth_config)
  let secret_key_base = wisp.random_string(64)

  let handler = router.handle_request(_, ctx)
  let assert Ok(_) =
    wisp_mist.handler(handler, secret_key_base)
    |> mist.new
    |> mist.bind("0.0.0.0")
    |> mist.port(3000)
    |> mist.start_http

  process.sleep_forever()
}
