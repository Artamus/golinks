import lustre/attribute.{action, method, name}
import lustre/element.{type Element, text}
import lustre/element/html.{button, div, form, h1, h2, input, span}

pub fn root() -> Element(t) {
  div([], [
    h1([], [text("go/")]),
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
  ])
}
