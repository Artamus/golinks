import golink.{type GoLink}
import lustre/attribute.{form_action, form_method}
import lustre/element.{type Element, text}
import lustre/element/html.{button, div, form, h1, span}

pub fn root(go_link: GoLink) -> Element(t) {
  div([], [
    h1([], [text("go/")]),
    div([], [
      span([], [text("http://go/" <> go_link.short)]),
      text(" -> "),
      text(go_link.long),
    ]),
    form([], [
      button(
        [
          form_method("POST"),
          form_action(
            "/shortlinks-admin/golink/" <> go_link.short <> "?_method=DELETE",
          ),
        ],
        [text("Delete")],
      ),
    ]),
  ])
}
