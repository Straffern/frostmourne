defmodule Frostmourne.DomainRegister.Tld do
  use Ecto.Schema

  schema "tld" do
    field :name, :string

    timestamps()
  end

end
