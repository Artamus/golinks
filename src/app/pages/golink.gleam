import golink.{type GoLink}
import lustre/attribute.{action, href, method}
import lustre/element.{type Element, text}
import lustre/element/html.{a, button, div, form, h1, span}

pub fn root(go_link: GoLink) -> Element(t) {
  div([], [
    h1([], [a([href("/")], [text("go/")])]),
    div([], [
      span([], [text("http://go/" <> go_link.short)]),
      text(" -> "),
      text(go_link.long),
    ]),
    form(
      [
        method("POST"),
        action(
          "/shortlinks-admin/golink/" <> go_link.short <> "?_method=DELETE",
        ),
      ],
      [button([], [text("Delete")])],
    ),
  ])
}
