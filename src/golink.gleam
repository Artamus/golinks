import gleam/result
import gleam/string
import gleam/uri

pub type GoLink {
  GoLink(short: String, long: String)
}

pub fn create(short: String, long: String) -> Result(GoLink, String) {
  let long_with_scheme = case string.starts_with(long, "http") {
    True -> long
    False -> "https://" <> long
  }

  uri.parse(long_with_scheme)
  |> result.replace_error("Unable to parse long link.")
  |> result.map(fn(uri) {
    let long = uri.to_string(uri)
    GoLink(short, long)
  })
}
