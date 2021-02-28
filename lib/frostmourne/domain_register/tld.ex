defmodule Frostmourne.Datastore.DomainRegister.Tld do
  use Ecto.Schema

  schema "tlds" do
    field :name, :string

    timestamps()
  end

end
