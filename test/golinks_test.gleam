import gleam/option.{Some}
import gleeunit
import gleeunit/should
import golink.{GoLink}
import golink_repository
import pog
import simplifile
import webapp/router
import webapp/web
import wisp
import wisp/testing

pub fn main() {
  gleeunit.main()
}

fn with_context(testcase: fn(web.Context) -> t) -> t {
  let assert Ok(priv_dir) = wisp.priv_directory("golinks")

  let db_conn =
    pog.default_config()
    |> pog.host("localhost")
    |> pog.database("golinks_test")
    |> pog.user("postgres")
    |> pog.password(Some("test"))
    |> pog.pool_size(1)
    |> pog.connect
  let _ =
    pog.query("truncate table go_links")
    |> pog.execute(db_conn)

  let assert Ok(schema) = simplifile.read(from: priv_dir <> "/db/schema.sql")
  let assert Ok(repository) = golink_repository.create(db_conn, schema)
  let ctx = web.Context(priv_dir <> "/static", repository)

  testcase(ctx)
}

pub fn home_page_redirects_test() {
  use ctx <- with_context
  let request = testing.get("/", [])

  let response = router.handle_request(request, ctx)

  response.status |> should.equal(303)
  response.headers |> should.equal([#("location", "/shortlinks-admin")])
}

pub fn admin_home_page_test() {
  use ctx <- with_context
  let request =
    testing.get("/shortlinks-admin", [
      #("X-Auth-Request-Email", "test@example.com"),
    ])

  let response = router.handle_request(request, ctx)

  response.status |> should.equal(200)
}

pub fn create_golink_test() {
  use ctx <- with_context
  let request =
    testing.post_form(
      "/shortlinks-admin/golink",
      [#("X-Auth-Request-Email", "test@example.com")],
      [#("short", "foo"), #("long", "www.foo.com")],
    )

  let response = router.handle_request(request, ctx)

  response.status |> should.equal(303)
  response.headers
  |> should.equal([#("location", "/shortlinks-admin/golink/foo")])
  golink_repository.get(ctx.repository, "foo")
  |> should.be_ok()
  |> should.equal(GoLink("foo", "https://www.foo.com/", "test@example.com"))
}

pub fn get_golink_test() {
  use ctx <- with_context
  let assert Ok(_) =
    golink_repository.save(
      ctx.repository,
      GoLink("bar", "http://bar.com/", "test@example.com"),
    )
  let request =
    testing.get("/shortlinks-admin/golink/bar", [
      #("X-Auth-Request-Email", "test@example.com"),
    ])

  let response = router.handle_request(request, ctx)

  response.status |> should.equal(200)
}

pub fn update_golink_test() {
  use ctx <- with_context
  let assert Ok(_) =
    golink_repository.save(
      ctx.repository,
      GoLink("fooz", "http://fooz.com/", "test@example.com"),
    )
  let request =
    testing.patch_form(
      "/shortlinks-admin/golink/fooz",
      [#("X-Auth-Request-Email", "test@example.com")],
      [#("long", "www.fooztwo.com")],
    )

  let response = router.handle_request(request, ctx)

  response.status |> should.equal(303)
  response.headers
  |> should.equal([#("location", "/shortlinks-admin/golink/fooz")])
  golink_repository.get(ctx.repository, "fooz")
  |> should.be_ok()
  |> should.equal(GoLink("fooz", "https://www.fooztwo.com/", "test@example.com"))
}

pub fn delete_go_link_test() {
  use ctx <- with_context
  let assert Ok(_) =
    golink_repository.save(
      ctx.repository,
      GoLink("baz", "http://baz.com/", "test@example.com"),
    )
  let request =
    testing.delete_form(
      "/shortlinks-admin/golink/baz",
      [#("X-Auth-Request-Email", "test@example.com")],
      [#("short", "foo"), #("long", "www.foo.com")],
    )

  let response = router.handle_request(request, ctx)

  response.status |> should.equal(303)
  response.headers
  |> should.equal([#("location", "/shortlinks-admin")])
}

pub fn resolve_go_link_test() {
  use ctx <- with_context
  let assert Ok(_) =
    golink_repository.save(
      ctx.repository,
      GoLink("zug", "http://zugzug.com/", "test@example.com"),
    )
  let request = testing.get("/zug", [])

  let response = router.handle_request(request, ctx)

  response.status |> should.equal(303)
  response.headers
  |> should.equal([#("location", "http://zugzug.com/")])
}
