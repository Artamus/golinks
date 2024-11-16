import gleam/dynamic
import gleam/result
import golink.{type GoLink, GoLink}
import pog.{ConnectionUnavailable}

pub type GoLinkRepository {
  DbRepository(conn: pog.Connection)
}

pub type Error {
  Unknown
}

pub fn create(
  conn: pog.Connection,
  schema: String,
) -> Result(GoLinkRepository, String) {
  let schema_result = pog.query(schema) |> pog.execute(conn)

  case schema_result {
    Ok(_) -> Ok(DbRepository(conn))
    Error(ConnectionUnavailable) -> Error("Could not connect to database.")
    Error(_) -> Error("Could not create database schema.")
  }
}

pub fn get(repository: GoLinkRepository, short: String) -> Result(GoLink, Nil) {
  let decoder =
    dynamic.decode2(
      GoLink,
      dynamic.element(0, dynamic.string),
      dynamic.element(1, dynamic.string),
    )
  let response =
    pog.query("select short, long from go_links where short=$1")
    |> pog.parameter(pog.text(short))
    |> pog.returning(decoder)
    |> pog.execute(repository.conn)
    |> result.replace_error(Nil)

  response
  |> result.try(fn(results) {
    case results.rows {
      [link] -> Ok(link)
      _ -> Error(Nil)
    }
  })
}

pub fn save(repository: GoLinkRepository, link: GoLink) -> Result(GoLink, Error) {
  let result =
    pog.query(
      "insert into go_links (short, long) values ($1,$2) on conflict (short) do update set long=$2;",
    )
    |> pog.parameter(pog.text(link.short))
    |> pog.parameter(pog.text(link.long))
    |> pog.execute(repository.conn)

  case result {
    Ok(_) -> Ok(link)
    Error(error) ->
      case error {
        _ -> Error(Unknown)
      }
  }
}

pub fn delete(repository: GoLinkRepository, short: String) {
  let _result =
    pog.query("delete from go_links where short=$1")
    |> pog.parameter(pog.text(short))
    |> pog.execute(repository.conn)
}

pub fn list(repository: GoLinkRepository) -> List(GoLink) {
  let decoder =
    dynamic.decode2(
      GoLink,
      dynamic.element(0, dynamic.string),
      dynamic.element(1, dynamic.string),
    )

  let links_rows =
    pog.query("select short, long from go_links")
    |> pog.returning(decoder)
    |> pog.execute(repository.conn)
  case links_rows {
    Ok(ret) -> ret.rows
    Error(_) -> []
  }
}
