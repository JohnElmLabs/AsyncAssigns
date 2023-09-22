# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     AsyncAssign.Repo.insert!(%AsyncAssign.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

attrs =
  [
    %{email: "john@johnelmlabs.com", password: "asdfasdfasdf"},
    %{email: "tim@johnelmlabs.com", password: "asdfasdfasdf"}
  ]
  |> Enum.map(fn attrs -> AsyncAssign.Accounts.register_user(attrs) end)
