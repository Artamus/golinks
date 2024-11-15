import gleam/list
import golink.{type GoLink}
import lustre/attribute.{
  action, class, for, href, id, method, name, placeholder, required, type_,
}
import lustre/element.{type Element, text}
import lustre/element/html.{
  a, button, div, form, h2, input, label, span, table, tbody, td, tr,
}

pub fn root(links: List(GoLink)) -> List(Element(t)) {
  [
    h2([class("text-xl font-bold pt-6 pb-2")], [text("Create a new golink")]),
    form(
      [
        method("POST"),
        action("/shortlinks-admin/golink"),
        class("flex flex-wrap"),
      ],
      [
        div([class("flex")], [
          label(
            [
              class(
                "flex my-2 px-2 items-center bg-fuchsia-200 border border-r-0 border-gray-300 rounded-l-md text-gray-700",
              ),
              for("short"),
            ],
            [text("http://go/")],
          ),
          input([
            class(
              "p-2 my-2 rounded-r-md border-gray-300 placeholder:text-gray-400",
            ),
            id("short"),
            name("short"),
            required(True),
            type_("text"),
            placeholder("shortname"),
          ]),
          span([class("flex m-2 items-center")], [text("→")]),
        ]),
        input([
          class(
            "p-2 my-2 mr-2 max-w-full border rounded-md border-gray-300 placeholder:text-gray-400",
          ),
          name("long"),
          required(True),
          placeholder("https://destination-url"),
        ]),
        button(
          [
            class(
              "py-2 px-4 my-2 rounded-md bg-blue-500 border-blue-500 text-white hover:bg-blue-600 hover:border-blue-600",
            ),
            type_("submit"),
          ],
          [text("Create")],
        ),
      ],
    ),
    h2([class("text-xl font-bold pt-6 pb-2")], [text("Your shortlinks")]),
    golinks(links),
  ]
}

fn golinks(golinks: List(GoLink)) -> Element(t) {
  table([class("table-auto w-full max-w-max")], [
    tbody([], golinks |> list.map(golink)),
  ])
}

fn golink(golink: GoLink) -> Element(t) {
  tr([class("hover:bg-gray-100 group border-b border-gray-200")], [
    td([class("flex")], [
      span([class("flex m-2 items-center")], [text("•")]),
      a(
        [
          class("block flex-1 p-2 pr-4 hover:text-blue-500 hover:underline"),
          href("/shortlinks-admin/golink/" <> golink.short),
        ],
        [text("go/" <> golink.short)],
      ),
    ]),
  ])
}
