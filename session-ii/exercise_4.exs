defmodule User do
  @enforce_keys [:name, :email]
  defstruct [:name, :email, :phone, :address]
end

defmodule Agenda do
  def init() do
    [
      %User{name: "Peter", email: "peter@mail.com", phone: "555555"},
      %User{name: "Rose", email: "rose@mail.com", phone: "666666"},
      %User{name: "John", email: "john@mail.com", phone: "777777"},
      %User{name: "Mary", email: "mary@mail.com", phone: "888888"}
    ]
  end

  def search_by_name(entries, query) do
    Enum.find(entries, fn %{name: name} -> name == query end)
  end

  def search_by_email(entries, query) do
    Enum.find(entries, fn %{email: email} -> email == query end)
  end
end

entries = Agenda.init()
IO.inspect(Agenda.search_by_name(entries, "Peter"))
IO.inspect(Agenda.search_by_email(entries, "rose@mail.com"))
IO.inspect(Agenda.search_by_email(entries, "nomail@mail.com"))
