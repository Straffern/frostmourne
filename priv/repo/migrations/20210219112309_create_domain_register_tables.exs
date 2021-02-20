defmodule Frostmourne.Repo.Migrations.CreateDomainRegisterTables do
  use Ecto.Migration

  def change do

    create table(:tld) do
      add :name, :citext, null: false
      timestamps()
    end

    create unique_index(:tld, [:name])


    create table(:domains) do
      add :name, :citext, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :tld_id, references(:tld, on_delete: :delete_all), null: false
      add :is_active, :boolean, null: false
      add :expiry, :naive_datetime

      timestamps()
    end

    create index(:domains, [:user_id, :tld_id])
    create unique_index(:domains, [:name, :tld_id])


  end
end
