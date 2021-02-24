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
  Returns all registered domains, like `needle`.

  Result is limited to 5, and is ordered by length of domain name.
  """

  def get_domains_like(needle)
    when is_binary(needle) do
    Domain
    |> join(:inner, [d], t in assoc(d, :tlds))
    |> where([d, t], like(d.name, ^needle))
    |> preload([:tlds])
    # |> order_by([d, t], asc: fragment("length(?)", d.name))
    |> limit(5)
    |> select([d, t], %{domain_name: d.name, tld_id: t.id, tld: t.name})
    |> Repo.all()
  end


  @doc """
  Returns all registered domains, with `domain_name` and tld in `tld_ids` list.

  Results are limited to length of tld_ids.
  """
  def get_domain_by_name_and_tlds(domain_name, tld_ids)
    when is_binary(domain_name) and is_list(tld_ids) do
    Domain
    |> join(:inner, [d], t in assoc(d, :tlds))
    |> where([d, t], d.name == ^domain_name and t.id in ^tld_ids)
    |> preload([:tlds])
    # |> order_by([d, t], asc: fragment("length(?)", t.name))
    |> select([d, t], %{domain_name: d.name, tld_id: t.id, tld: t.name})
    |> Repo.all()
  end


  @doc """
  Returns list of all tlds with name like `needle`.

  ## Examples

      iex> get_tlds("com")
      [%Tld{id: 1, name: "com"}, %Tld{id: 13, name: "comma"}]

  """
  def get_tlds_like(needle)
    when is_binary(needle) do
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
