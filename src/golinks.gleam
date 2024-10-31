import gleam/bit_array
import gleam/bytes_builder
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/result
import gleam/string
import golink
import golink_repository
import mist.{type Connection, type ResponseData}

pub fn main() {
  let assert Ok(golink_repository) = golink_repository.create()

  let not_found =
    response.new(404)
    |> response.set_body(mist.Bytes(bytes_builder.new()))

  let assert Ok(_) =
    fn(req: Request(Connection)) -> Response(ResponseData) {
      case request.path_segments(req) {
        ["echo"] -> echo_body(req)
        ["shortlink", "save", short_link] ->
          save(req, short_link, golink_repository)
        ["shortlink", "delete", short_link] ->
          delete(short_link, golink_repository)
        ["shortlink", "list"] -> not_found
        ["resolve", short_link, ..tail] ->
          resolve(short_link, tail, golink_repository)
        _ -> not_found
      }
    }
    |> mist.new
    |> mist.port(3000)
    |> mist.start_http

  process.sleep_forever()
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

fn save(
  request: Request(Connection),
  short_link: String,
  repository: golink_repository.GoLinkRepository,
) -> Response(ResponseData) {
  let save_result =
    mist.read_body(request, 1024 * 1024 * 10)
    |> result.replace_error("could not read request body")
    |> result.map(fn(req_body) {
      bit_array.to_string(req_body.body)
      |> result.replace_error("could not convert request body to string")
    })
    |> result.flatten
    |> result.map(fn(long_link) {
      let go_link = golink.GoLink(short_link, long_link)
      golink_repository.save(repository, go_link)
    })
    |> result.flatten

  save_result
  |> result.map(fn(_) {
    response.new(200) |> response.set_body(mist.Bytes(bytes_builder.new()))
  })
  |> result.map_error(fn(e) {
    response.new(400)
    |> response.set_body(mist.Bytes(bytes_builder.from_string(e)))
  })
  |> result.unwrap_both
}

fn delete(
  short_link: String,
  repository: golink_repository.GoLinkRepository,
) -> Response(ResponseData) {
  golink_repository.delete(repository, short_link)
  response.new(200) |> response.set_body(mist.Bytes(bytes_builder.new()))
}

fn resolve(
  short_link: String,
  tail: List(String),
  repository: golink_repository.GoLinkRepository,
) -> Response(ResponseData) {
  golink_repository.get(repository, short_link)
  |> result.map(fn(link) {
    let long_link = [link.long, ..tail] |> string.join("/")
    response.new(301)
    |> response.set_header("Location", long_link)
    |> response.set_body(mist.Bytes(bytes_builder.new()))
  })
  |> result.lazy_unwrap(fn() {
    response.new(404)
    |> response.set_body(mist.Bytes(bytes_builder.new()))
  })
}
