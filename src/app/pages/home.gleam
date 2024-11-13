import gleam/list
import golink.{type GoLink}
import lustre/attribute.{action, href, method, name}
import lustre/element.{type Element, text}
import lustre/element/html.{a, button, div, form, h1, h2, input, li, span, ul}

pub fn root(links: List(GoLink)) -> Element(t) {
  div([], [
    h1([], [a([href("/")], [text("go/")])]),
    h2([], [text("Create a new golink")]),
    form([method("POST"), action("/shortlinks-admin/golink")], [
      div([], [
        span([], [text("http://go/")]),
        input([name("short")]),
        text(" -> "),
        input([name("long")]),
        button([], [text("Create")]),
      ]),
    ]),
    h2([], [text("Your golinks")]),
    golinks(links),
  ])
}

fn golinks(golinks: List(GoLink)) -> Element(t) {
  ul([], golinks |> list.map(golink))
}

fn golink(golink: GoLink) -> Element(t) {
  li([], [
    a([href("/shortlinks-admin/golink/" <> golink.short)], [text(golink.short)]),
  ])
}
