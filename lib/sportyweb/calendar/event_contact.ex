defmodule Sportyweb.Calendar.EventContact do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "event_contacts" do
    belongs_to :event,   Sportyweb.Calendar.Event,   type: :binary_id
    belongs_to :contact, Sportyweb.Personal.Contact, type: :binary_id
    field :role, :string, default: "participant"
    timestamps()
  end

  def changeset(event_contacts, attrs) do
    event_contacts
    |> cast(
      attrs,
      [
        :event_id,
        :contact_id,
        :role
      ]
    )
    |> validate_required([:event_id, :contact_id])
    |> validate_inclusion(:role, ["participant", "organizer","waitinglist"])
  end
end
