import golink.{type GoLink}
import lustre/attribute.{
  action, class, href, method, name, required, type_, value,
}
import lustre/element.{type Element, text}
import lustre/element/html.{a, button, div, form, input, span}

pub fn root(link: GoLink) -> Element(t) {
  div([class("flex flex-col")], [
    form(
      [
        class("flex flex-wrap"),
        method("POST"),
        action("/shortlinks-admin/golink/" <> link.short <> "?_method=PATCH"),
      ],
      [
        div([class("flex font-semibold")], [
          a(
            [
              class(
                "flex my-2 px-2 items-center bg-fuchsia-200 border border-r-0 border-gray-300 rounded-md text-gray-700 hover:text-blue-500 hover:underline",
              ),
              href("/" <> link.short),
            ],
            [text("http://go/" <> link.short)],
          ),
          span([class("flex m-2 items-center")], [text("→")]),
        ]),
        input([
          class(
            "p-2 my-2 mr-2 max-w-full border rounded-md border-gray-300 placeholder:text-gray-400",
          ),
          name("long"),
          required(True),
          value(link.long),
        ]),
        button(
          [
            class(
              "py-2 px-4 my-2 rounded-md bg-indigo-500 border-indigo-500 text-white hover:bg-indigo-600 hover:border-indigo-600",
            ),
            type_("submit"),
          ],
          [text("Update")],
        ),
      ],
    ),
    form(
      [
        method("POST"),
        action("/shortlinks-admin/golink/" <> link.short <> "?_method=DELETE"),
      ],
      [
        button(
          [
            class(
              "py-2 px-4 my-2 rounded-md bg-rose-600 border-rose-600 text-white hover:bg-rose-700 hover:border-rose-700",
            ),
            type_("submit"),
          ],
          [text("Delete")],
        ),
      ],
    ),
  ])
}
