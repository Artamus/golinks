import lustre/attribute.{class, href, src, target, width}
import lustre/element.{type Element}
import lustre/element/html.{a, div, footer, h1, header, img, main, text}

pub fn layout(elements: List(Element(t))) -> Element(t) {
  html.html([], [
    html.head([], [
      html.title([], "Golinks Admin"),
      html.meta([
        attribute.name("viewport"),
        attribute.attribute("content", "width=device-width, initial-scale=1"),
      ]),
      html.link([
        attribute.rel("stylesheet"),
        attribute.href("/static/css/app.css"),
      ]),
    ]),
    html.body([class("flex flex-col min-h-screen")], [
      div([class("bg-fuchsia-300 border-b border-gray-200 pt-4 pb-2 mb-6")], [
        header([class("container mx-auto px-4")], [
          h1([class("text-2xl font-bold pb-1")], [
            a([href("/shortlinks-admin")], [text("go/")]),
          ]),
          text("Internal shortlinks"),
        ]),
      ]),
      main([class("container mx-auto px-4 flex-1")], elements),
      footer([class("bg-fuchsia-200 border-t border-gray-200 pt-2 pb-2 mt-6")], [
        div([class("container mx-auto px-4 leading-6 text-right")], [
          text("Made with ❤️ using "),
          a(
            [
              class("font-semibold"),
              href("https://gleam.run/"),
              target("_blank"),
            ],
            [
              img([class("inline w-6 mr-1"), width(24), src("/static/lucy.svg")]),
              text("Gleam."),
            ],
          ),
        ]),
      ]),
    ]),
  ])
}
