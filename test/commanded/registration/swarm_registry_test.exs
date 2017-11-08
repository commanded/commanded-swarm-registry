# execute all tests from Commanded
[
  "deps/commanded/test/aggregates/**/*.exs",
  "deps/commanded/test/commands/**/*.exs",
  "deps/commanded/test/event/**/*.exs",
  "deps/commanded/test/process_managers/**/*.exs",
  "deps/commanded/test/subscriptions/**/*.exs",
]
|> Enum.flat_map(&Path.wildcard/1)
|> Enum.each(&Code.require_file/1)
