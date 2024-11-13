import gleam/dynamic
import gleam/result
import golink.{type GoLink, GoLink}
import pog

pub type GoLinkRepository {
  DbRepository(conn: pog.Connection)
}

pub type Error {
  Unknown
  AlreadyExists
}

pub fn create(conn: pog.Connection) -> GoLinkRepository {
  DbRepository(conn)
}

pub fn get(repository: GoLinkRepository, short: String) -> Result(GoLink, Nil) {
  let decoder =
    dynamic.decode2(
      GoLink,
      dynamic.element(0, dynamic.string),
      dynamic.element(1, dynamic.string),
    )
  let response =
    pog.query("select short, long from golinks where short=$1")
    |> pog.parameter(pog.text(short))
    |> pog.returning(decoder)
    |> pog.execute(repository.conn)
    |> result.replace_error(Nil)

  response
  |> result.try(fn(results) {
    case results.rows {
      [golink] -> Ok(golink)
      _ -> Error(Nil)
    }
  })
}

pub fn save(repository: GoLinkRepository, link: GoLink) -> Result(GoLink, Error) {
  let result =
    pog.query("insert into golinks (short, long) values ($1,$2);")
    |> pog.parameter(pog.text(link.short))
    |> pog.parameter(pog.text(link.long))
    |> pog.execute(repository.conn)

  case result {
    Ok(_) -> Ok(link)
    Error(error) ->
      case error {
        pog.ConstraintViolated(_, _, _) -> Error(AlreadyExists)
        _ -> Error(Unknown)
      }
  }
}

pub fn delete(repository: GoLinkRepository, short: String) {
  let _result =
    pog.query("delete from golinks where short=$1")
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

  let asd =
    pog.query("select short, long from golinks")
    |> pog.returning(decoder)
    |> pog.execute(repository.conn)
  case asd {
    Ok(foo) -> foo.rows
    Error(_) -> []
  }
}
