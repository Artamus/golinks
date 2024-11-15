import golink.{type GoLink}
import lustre/attribute.{action, class, href, method, type_}
import lustre/element.{type Element, text}
import lustre/element/html.{a, button, div, form}

pub fn root(link: GoLink) -> Element(t) {
  div([class("flex flex-col")], [
    div([class("font-semibold")], [
      a(
        [
          class("hover:text-blue-500 hover:underline"),
          href("http://go/" <> link.short),
        ],
        [text("http://go/" <> link.short)],
      ),
      text(" → "),
      a([class("hover:text-blue-500 hover:underline"), href(link.long)], [
        text(link.long),
      ]),
    ]),
    form(
      [
        method("POST"),
        action("/shortlinks-admin/golink/" <> link.short <> "?_method=DELETE"),
      ],
      [
        button(
          [
            class(
              "py-2 px-4 my-2 rounded-md bg-red-500 border-red-500 text-white hover:bg-red-600 hover:border-red-600",
            ),
            type_("submit"),
          ],
          [text("Delete")],
        ),
      ],
    ),
  ])
}
