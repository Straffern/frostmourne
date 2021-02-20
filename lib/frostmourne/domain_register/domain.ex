defmodule Frostmourne.DomainRegister.Domain do
  use Ecto.Schema
  import Ecto.Changeset

  @minute 60
  @hour @minute*60
  @day @hour*24

  @claimed_duration 7*@day
  @assigned_duration 365*@day

  @derive {Inspect, only: [:name]}
  schema "domains" do
    field :name, :string
    belongs_to :tld, Frostmourne.DomainRegister.Tld
    belongs_to :user, Frostmourne.Accounts.User
    field :is_active, :boolean, default: false
    field :expiry, :naive_datetime

    timestamps()
  end

  @required_fields ~w(name tld_id user_id)a


  @doc """
  A record changeset for registration.
  """
  def registration_changeset(domain, attrs) do
    domain
    |> cast(attrs, @required_fields)
    |> validate_domain_name()
    |> validate_constraints()
  end

  defp validate_domain_name(changeset) do
    changeset
    |> validate_required([:name])
    |> validate_format(:name, ~r/^[a-zA-Z0-9]+(-[a-zA-Z0-9]+)*/, message: "domain must be of the right format")
    |> validate_length(:name, max: 63)
  end

  defp validate_constraints(changeset) do
    changeset
    |> assoc_constraint(:user)
    |> assoc_constraint(:tld)
    |> unsafe_validate_unique([:name, :tld_id], Frostmourne.Repo)
    |> unique_constraint([:name, :tld_id])
  end

  def claim_changeset(domain, context) do
    then = NaiveDateTime.utc_now()
        |> NaiveDateTime.add(days_for_context(context))
        |> NaiveDateTime.truncate(:second)
    change(domain, expiry: then)
  end

  defp days_for_context("Claim"), do: @claimed_duration
  defp days_for_context("Assigned"), do: @assigned_duration



end
