import gleam/bytes_builder
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/result
import mist.{type Connection, type ResponseData}

pub fn main() {
  let not_found =
    response.new(404)
    |> response.set_body(mist.Bytes(bytes_builder.new()))

  let assert Ok(_) =
    fn(req: Request(Connection)) -> Response(ResponseData) {
      case request.path_segments(req) {
        ["echo"] -> echo_body(req)
        ["shortlink", "save"] -> save(req)
        ["shortlink", "delete"] -> delete(req)
        ["shortlink", "list"] -> list(req)
        ["resolve", short_link, ..tail] -> resolve(short_link, tail)
        _ -> not_found
      }
    }
    |> mist.new
    |> mist.port(3000)
    |> mist.start_http

  process.sleep_forever()
}

fn resolve(short_link: String, tail: List(String)) -> Response(ResponseData) {
  todo
}

fn save(request: Request(Connection)) -> Response(ResponseData) {
  todo
}

fn delete(request: Request(Connection)) -> Response(ResponseData) {
  todo
}

fn list(request: Request(Connection)) -> Response(ResponseData) {
  todo
}

fn echo_body(request: Request(Connection)) -> Response(ResponseData) {
  let content_type =
    request
    |> request.get_header("content-type")
    |> result.unwrap("text/plain")

  mist.read_body(request, 1024 * 1024 * 10)
  |> result.map(fn(req) {
    response.new(200)
    |> response.set_body(mist.Bytes(bytes_builder.from_bit_array(req.body)))
    |> response.set_header("content-type", content_type)
  })
  |> result.lazy_unwrap(fn() {
    response.new(400)
    |> response.set_body(mist.Bytes(bytes_builder.new()))
  })
}
