import carpenter/table.{type Set}
import gleam/list
import gleam/result
import golink.{type GoLink}

pub type GoLinkRepository {
  Repository(table: Set(String, GoLink))
}

pub type Error {
  AlreadyExists
}

pub fn create() -> Result(GoLinkRepository, Nil) {
  table.build("golinks")
  |> table.privacy(table.Public)
  |> table.write_concurrency(table.AutoWriteConcurrency)
  |> table.read_concurrency(True)
  |> table.decentralized_counters(True)
  |> table.compression(False)
  |> table.set
  |> result.map(fn(table) { Repository(table) })
}

pub fn get(repository: GoLinkRepository, short: String) -> Result(GoLink, Nil) {
  repository.table
  |> table.lookup(short)
  |> list.first
  |> result.map(fn(search_result) {
    let #(_, link) = search_result
    link
  })
}

pub fn save(repository: GoLinkRepository, link: GoLink) -> Result(GoLink, Error) {
  case table.contains(repository.table, link.short) {
    True -> Error(AlreadyExists)
    False -> {
      repository.table |> table.insert([#(link.short, link)])
      Ok(link)
    }
  }
}

pub fn delete(repository: GoLinkRepository, short_link: String) {
  repository.table |> table.delete(short_link)
}
