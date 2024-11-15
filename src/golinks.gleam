import app/router
import app/web.{Context}
import gleam/erlang/process
import gleam/option.{Some}
import golink_repository
import mist
import pog
import wisp
import wisp/wisp_mist

pub fn main() {
  wisp.configure_logger()

  // TODO: Read from some config.
  let db_conn =
    pog.default_config()
    |> pog.host("localhost")
    |> pog.database("db")
    |> pog.user("postgres")
    |> pog.password(Some("test"))
    |> pog.pool_size(15)
    |> pog.connect
  let assert Ok(repository) = golink_repository.create(db_conn)

  let assert Ok(static_directory) = wisp.priv_directory("golinks")

  let ctx = Context(static_directory, repository)
  let secret_key_base = wisp.random_string(64)

  let handler = router.handle_request(_, ctx)
  let assert Ok(_) =
    wisp_mist.handler(handler, secret_key_base)
    |> mist.new
    |> mist.port(3000)
    |> mist.start_http

  process.sleep_forever()
}
