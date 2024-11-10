import app/web.{type Context}
import gleam/http.{Delete, Get}
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam/string_builder
import golink
import golink_repository.{type GoLinkRepository}
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    [] ->
      wisp.html_response(
        string_builder.from_string(
          "<h1>Page listing your owned shortlinks and HTML to create a new one and ability to delete the existing ones.</h1><form method=\"POST\" action=\"/shortlinks-admin/golink\"><input type=\"text\" id=\"short\" name=\"short\"><input type=\"text\" id=\"long\" name=\"long\"><button type=\"submit\">Create</button></form>",
        ),
        200,
      )
    ["shortlinks-admin", "golink"] -> save(req, ctx.repository)
    ["shortlinks-admin", "golink", short_link] ->
      golink_endpoints(req, short_link, ctx.repository)
    [short_link, ..tail] -> resolve(short_link, tail, ctx.repository)
  }
}

fn golink_endpoints(
  req: Request,
  short_link: String,
  golink_repository: GoLinkRepository,
) -> Response {
  case req.method {
    Get -> get(short_link, golink_repository)
    Delete -> delete(short_link, golink_repository)
    _ -> wisp.method_not_allowed([Get, Delete])
  }
}

fn save(req: Request, repository: GoLinkRepository) -> Response {
  use formdata <- wisp.require_form(req)

  io.debug(formdata.values)
  let go_link = {
    use short_link <- result.try(
      list.key_find(formdata.values, "short")
      |> result.map_error(fn(_) { "Required key \"short\" is missing." }),
    )
    use long_link <- result.try(
      list.key_find(formdata.values, "long")
      |> result.map_error(fn(_) { "Required key \"long\" is missing." }),
    )

    let go_link = golink.GoLink(short_link, long_link)
    Ok(go_link)
  }

  let save_result =
    result.try(go_link, fn(link) {
      golink_repository.save(repository, link)
      |> result.map_error(fn(err) {
        case err {
          golink_repository.AlreadyExists -> "This shortlink is already taken."
        }
      })
    })

  case save_result {
    Ok(go_link) ->
      wisp.redirect(to: "/shortlinks-admin/golink/" <> go_link.short)
    Error(err) -> wisp.bad_request() |> wisp.string_body(err)
  }
}

fn get(short_link: String, repository: GoLinkRepository) -> Response {
  let resolved = golink_repository.get(repository, short_link)
  case resolved {
    Ok(go_link) ->
      wisp.html_response(
        string_builder.from_string(
          "<h1>go/</h1><br>"
          <> go_link.short
          <> " -> "
          <> go_link.long
          <> "<br><form method=\"POST\" action=\"/shortlinks-admin/golink/"
          <> go_link.short
          <> "?_method=DELETE\"><button name=\"delete\" value=\"delete\">Delete</button></form>",
        ),
        200,
      )
    Error(Nil) -> wisp.not_found()
  }
}

fn delete(short_link: String, repository: GoLinkRepository) -> Response {
  golink_repository.delete(repository, short_link)
  wisp.redirect(to: "/")
}

fn resolve(
  short_link: String,
  tail: List(String),
  repository: GoLinkRepository,
) -> Response {
  let resolved =
    golink_repository.get(repository, short_link)
    |> result.map(fn(link) { [link.long, ..tail] |> string.join("/") })

  case resolved {
    Ok(long_link) -> wisp.redirect(long_link)
    Error(Nil) -> wisp.not_found()
  }
}
