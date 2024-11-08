import golink_repository
import wisp

pub type Context {
  Context(repository: golink_repository.GoLinkRepository)
}

pub fn middleware(
  req: wisp.Request,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  let req = wisp.method_override(req)
  use req <- wisp.handle_head(req)
  use <- wisp.rescue_crashes

  handle_request(req)
}
