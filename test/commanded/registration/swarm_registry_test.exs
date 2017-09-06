# execute all tests from Commanded
"deps/commanded/test/aggregates/**/*.exs"
|> Path.wildcard()
|> Enum.each(&Code.require_file/1)
