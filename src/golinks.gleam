import app/router
import app/web.{Context}
import gleam/erlang/process
import golink_repository
import mist
import wisp
import wisp/wisp_mist

pub fn main() {
  wisp.configure_logger()

  let assert Ok(golink_repository) = golink_repository.create()

  let ctx = Context(golink_repository)
  let secret_key_base = wisp.random_string(64)

  let handler = router.handle_request(_, ctx)
  let assert Ok(_) =
    wisp_mist.handler(handler, secret_key_base)
    |> mist.new
    |> mist.port(3000)
    |> mist.start_http

  process.sleep_forever()
}
