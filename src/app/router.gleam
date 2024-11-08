import app/web.{type Context}
import gleam/result
import gleam/string
import gleam/string_builder
import golink
import golink_repository.{type GoLinkRepository}
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    ["shortlink", "save", short_link] -> save(req, short_link, ctx.repository)
    ["shortlink", "delete", short_link] -> delete(short_link, ctx.repository)
    ["resolve", short_link, ..tail] -> resolve(short_link, tail, ctx.repository)
    _ -> wisp.html_response(string_builder.new(), 404)
  }
}

fn save(
  req: Request,
  short_link: String,
  repository: GoLinkRepository,
) -> Response {
  use long_link <- wisp.require_string_body(req)

  let go_link = golink.GoLink(short_link, long_link)
  let save_res = golink_repository.save(repository, go_link)

  case save_res {
    Ok(Nil) -> wisp.created()
    Error(err) -> wisp.bad_request() |> wisp.string_body(err)
  }
}

fn delete(short_link: String, repository: GoLinkRepository) -> Response {
  golink_repository.delete(repository, short_link)
  wisp.ok()
}

fn resolve(
  short_link: String,
  tail: List(String),
  repository: GoLinkRepository,
) -> Response {
  let foo =
    golink_repository.get(repository, short_link)
    |> result.map(fn(link) { [link.long, ..tail] |> string.join("/") })

  case foo {
    Ok(long_link) -> wisp.redirect(long_link)
    Error(Nil) -> wisp.not_found()
  }
}
