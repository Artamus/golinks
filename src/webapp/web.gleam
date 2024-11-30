import golink_repository
import webapp/authentication_config.{type AuthenticationConfig}
import wisp

pub type Context {
  Context(
    static_directory: String,
    repository: golink_repository.GoLinkRepository,
    authentication_config: AuthenticationConfig,
  )
}

pub fn middleware(
  req: wisp.Request,
  ctx: Context,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  let req = wisp.method_override(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)
  use <- wisp.serve_static(req, under: "/static", from: ctx.static_directory)

  handle_request(req)
}
