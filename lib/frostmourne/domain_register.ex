defmodule Frostmourne.DomainRegister do
  @moduledoc """
  The Domains context
  """
  import Ecto.Query, warn: false

  alias Frostmourne.Repo
  alias Frostmourne.DomainRegister.{Tld, Record}

  def register_domain(attrs) do
    %Record{}
    |> Record.registration_changeset(attrs)
    |> Record.claim_changeset("Claim")
    |> Repo.insert()
  end

  @doc """
  Returns all registered domains, given a domain name.
  """
  # ? Consider creating a helper function for get_registered_domains.
  def get_registered_domains(domain_name) do
    query =
      from(record in Record,
        join: tld in assoc(record, :tld),
        where: record.domain_name == ^domain_name,
        preload: [tld: tld],
        select: {record.domain_name, tld.name}
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
      from(record in Record,
        join: tld in assoc(record, :tld),
        where:
          record.domain_name == ^domain_name and
            like(tld.name, ^tld + "%"),
        preload: [tld: tld],
        select: %{domain_name: record.domain_name, tld: tld.name}
      )
    try do
      {:ok, Repo.all(query)}
    rescue
      _e in Ecto.Query.CastError -> {:error, :cast_error}
      _e in Ecto.QueryError -> {:error, :query_error}
    end
  end

  @doc """
  Returns the list of tlds, that a domain can be registered with.
  """
  def get_tlds() do
    query =
      from(tld in Tld,
        select: %{tld: tld.name}
      )
    try do
      {:ok, Repo.all(query)}
    rescue
      _e in Ecto.Query.CastError -> {:error, :cast_error}
      _e in Ecto.QueryError -> {:error, :query_error}
    end

  end
end
