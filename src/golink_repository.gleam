import gleam/dynamic
import gleam/list
import gleam/result
import gleam/string
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
  let schema_statements = string.split(schema, "\n\n")

  let schema_result =
    schema_statements
    |> list.map(fn(statement) { pog.query(statement) |> pog.execute(conn) })
    |> result.all()

  case schema_result {
    Ok(_) -> Ok(DbRepository(conn))
    Error(ConnectionUnavailable) -> Error("Could not connect to database.")
    Error(_) -> Error("Could not create database schema.")
  }
}

pub fn get(repository: GoLinkRepository, short: String) -> Result(GoLink, Nil) {
  let decoder = golink_decoder()
  let response =
    pog.query("select short, long, owner from go_links where short=$1")
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
      "insert into go_links (short, long, owner) values ($1,$2,$3) on conflict (short) where owner=$3 do update set long=$2, updated_at=CURRENT_TIMESTAMP;",
    )
    |> pog.parameter(pog.text(link.short))
    |> pog.parameter(pog.text(link.long))
    |> pog.parameter(pog.text(link.owner))
    |> pog.execute(repository.conn)

  case result {
    Ok(_) -> Ok(link)
    Error(error) ->
      case error {
        _ -> Error(Unknown)
      }
  }
}

pub fn delete(repository: GoLinkRepository, short: String, owner: String) {
  let _result =
    pog.query("delete from go_links where short=$1 and owner=$2")
    |> pog.parameter(pog.text(short))
    |> pog.parameter(pog.text(owner))
    |> pog.execute(repository.conn)
}

pub fn list(repository: GoLinkRepository, owner: String) -> List(GoLink) {
  let decoder = golink_decoder()

  let links_rows =
    pog.query("select short, long, owner from go_links where owner=$1")
    |> pog.parameter(pog.text(owner))
    |> pog.returning(decoder)
    |> pog.execute(repository.conn)
  case links_rows {
    Ok(ret) -> ret.rows
    Error(_) -> []
  }
}

fn golink_decoder() -> fn(dynamic.Dynamic) ->
  Result(GoLink, List(dynamic.DecodeError)) {
  dynamic.decode3(
    GoLink,
    dynamic.element(0, dynamic.string),
    dynamic.element(1, dynamic.string),
    dynamic.element(2, dynamic.string),
  )
}
