defmodule Sportyweb.Repo.Migrations.CreateEventContacts do
  use Ecto.Migration

  def change do
    create table(:event_contacts, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :event_id, references(:events, on_delete: :delete_all, type: :binary_id), null: false
      add :contact_id, references(:contacts, on_delete: :delete_all, type: :binary_id), null: false
      add :role, :string, null: false, default: "participant"
      timestamps(type: :utc_datetime)
    end

    create index(:event_contacts, [:event_id])
    create index(:event_contacts, [:contact_id])
    create index(:event_contacts, [:event_id, :contact_id, :role], unique: true)
  end
end
