import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

pub fn layout(elements: List(Element(t))) -> Element(t) {
  html.html([], [
    html.head([], [
      html.title([], "Golinks Admin"),
      html.meta([
        attribute.name("viewport"),
        attribute.attribute("content", "width=device-width, initial-scale=1"),
      ]),
    ]),
    html.body([], elements),
  ])
}
