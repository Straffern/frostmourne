defmodule Frostmourne.DomainRegister do
  @moduledoc """
  The Domains context
  """
  import Ecto.Query, warn: false

  alias Frostmourne.Repo
  alias Frostmourne.DomainRegister.{Tld, Domain}

  def register_domain(attrs) do
    %Domain{}
    |> Domain.registration_changeset(attrs)
    |> Domain.claim_changeset("Claim")
    |> Repo.insert()
  end

  @doc """
  Returns all registered domains, given a domain name.
  """
  # ? Consider creating a helper function for get_registered_domains.
  def get_registered_domains(domain_name) do
    query =
      from(domain in Domain,
        join: tld in assoc(domain, :tld),
        where: domain.name == ^domain_name,
        preload: [tld: tld],
        select: {domain.name, tld.name}
      )
    try do
      {:ok, Repo.all(query)}
    rescue
      _e in Ecto.Query.CastError -> {:error, :cast_error}
      _e in Ecto.QueryError -> {:error, :query_error}
    end
  end

  @doc """
  Returns all registered domains, given a domain name and a tld.

  OBS: This performs a like operation on tld. To avoid 'LIKE' DOS attacks,
  please ensure to sanitize userinput.
  """
  def get_registered_domains(domain_name, tld) do
    query =
      from(domain in Domain,
        join: tld in assoc(domain, :tld),
        where:
          domain.name == ^domain_name and
            like(tld.name, ^tld + "%"),
        preload: [tld: tld],
        select: %{domain_name: domain.name, tld: tld.name}
      )
    try do
      {:ok, Repo.all(query)}
    rescue
      _e in Ecto.Query.CastError -> {:error, :cast_error}
      _e in Ecto.QueryError -> {:error, :query_error}
    end
  end



  @doc """
  Returns list of all tlds starting with `name`.

  ## Examples

      iex> get_tlds("com")
      {:ok, [%Tld{id: 1, name: "com"}, %Tld{id: 13, name: "comma"}]}

  """
  def get_tlds_starting_with(name) do
    needle = name <> "%"
    Tld
    |> where([tld], like(tld.name, ^needle))
    |> select([:id, :name])
    |> Repo.all()
  end

  @doc """
  Returns list of all tlds.
  """
  def get_tlds() do
    Tld
    |> select([:id, :name])
    |> Repo.all()
  end

end
