import app/pages/golink as golink_page
import app/pages/home
import app/pages/layout
import app/web.{type Context}
import gleam/http.{Delete, Get, Patch}
import gleam/list
import gleam/result
import gleam/string
import golink
import golink_repository.{type GoLinkRepository}
import lustre/element
import wisp.{type Request, type Response}

pub fn handle_request(req: Request, ctx: Context) -> Response {
  use req <- web.middleware(req, ctx)

  case wisp.path_segments(req) {
    [] -> {
      let links = golink_repository.list(ctx.repository)

      home.root(links)
      |> layout.layout
      |> element.to_document_string_builder
      |> wisp.html_response(200)
    }
    ["shortlinks-admin", "golink"] -> create(req, ctx.repository)
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
    Patch -> update(req, short_link, golink_repository)
    _ -> wisp.method_not_allowed([Get, Delete, Patch])
  }
}

fn create(req: Request, repository: GoLinkRepository) -> Response {
  use formdata <- wisp.require_form(req)

  let go_link = {
    use short_link <- result.try(
      list.key_find(formdata.values, "short")
      |> result.replace_error("Required key \"short\" is missing."),
    )
    use long_link <- result.try(
      list.key_find(formdata.values, "long")
      |> result.replace_error("Required key \"long\" is missing."),
    )

    golink.create(short_link, long_link)
  }

  let save_result =
    result.try(go_link, fn(link) {
      golink_repository.save(repository, link)
      |> result.map_error(fn(err) {
        case err {
          golink_repository.Unknown -> "Unknown error."
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
      [golink_page.root(go_link)]
      |> layout.layout
      |> element.to_document_string_builder
      |> wisp.html_response(200)
    Error(Nil) -> wisp.not_found()
  }
}

fn update(
  req: Request,
  short_link: String,
  repository: GoLinkRepository,
) -> Response {
  use formdata <- wisp.require_form(req)

  let go_link = {
    use long_link <- result.try(
      list.key_find(formdata.values, "long")
      |> result.replace_error("Required key \"long\" is missing."),
    )

    golink.create(short_link, long_link)
  }

  let save_result =
    result.try(go_link, fn(link) {
      golink_repository.save(repository, link)
      |> result.map_error(fn(err) {
        case err {
          golink_repository.Unknown -> "Unknown error."
        }
      })
    })

  case save_result {
    Ok(go_link) ->
      wisp.redirect(to: "/shortlinks-admin/golink/" <> go_link.short)
    Error(err) -> wisp.bad_request() |> wisp.string_body(err)
  }
}

fn delete(short_link: String, repository: GoLinkRepository) -> Response {
  let _ = golink_repository.delete(repository, short_link)
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
    Ok(long_link) -> {
      wisp.redirect(long_link)
    }
    Error(Nil) -> wisp.not_found()
  }
}
