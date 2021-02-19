defmodule Frostmourne.DomainRegister.Record do
  use Ecto.Schema
  import Ecto.Changeset

  @minute 60
  @hour @minute*60
  @day @hour*24

  @claimed_duration 7*@day
  @assigned_duration 365*@day

  @derive {Inspect, only: [:domain_name]}
  schema "records" do
    field :domain_name, :string
    belongs_to :tld, Frostmourne.DomainRegister.Tld
    belongs_to :user, Frostmourne.Accounts.User
    field :is_active, :boolean, default: false
    field :claimed_until, :naive_datetime
    field :points_to, :string, default: "0.0.0.0"

    timestamps()
  end

  @required_fields ~w(domain_name tld_id user_id)a
  @optional_fields ~w(points_to)a

  @doc """
  A record changeset for registration.
  """
  def registration_changeset(record, attrs) do
    record
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_domain_name()
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:tld_id)
    |> unsafe_validate_unique([:domain_name, :tld_id], Frostmourne.Repo)
    |> unique_constraint([:domain_name, :tld_id])
  end

  defp validate_domain_name(changeset) do
    changeset
    |> validate_required([:domain_name])
    |> validate_format(:domain_name, ~r/^[a-zA-Z0-9]+(-[a-zA-Z0-9]+)*/, message: "domain must be of the right format")
    |> validate_length(:domain_name, max: 63)
  end

  def claim_changeset(record, context) do
    then = NaiveDateTime.utc_now()
        |> NaiveDateTime.add(days_for_context(context))
        |> NaiveDateTime.truncate(:second)
    change(record, claimed_until: then)
  end

  defp days_for_context("Claim"), do: @claimed_duration
  defp days_for_context("Assigned"), do: @assigned_duration



end
