defmodule SportywebWeb.ParticipantLive.IndexTableComponent do
  use SportywebWeb, :html
  import SportywebWeb.CommonHelper

  alias Sportyweb.Personal.Contact
  alias Sportyweb.Calendar.Event
  alias Sportyweb.Calendar.EventContact
  alias Sportyweb.Repo


  attr :event_contacts, :list, required: true

  def render(assigns) do
    ~H"""
    <div>
      <.table id="participants" rows={@event_contacts} row_click={&JS.navigate(~p"/contacts/#{&1.contact_id}")}>
        <:col :let={ec} label="Name">
          {format_string_field(ec.contact.name)}
        </:col>
        <:col :let={ec} label="Art">
          {get_key_for_value(Sportyweb.Personal.Contact.get_valid_types(), ec.contact.type)}
        </:col>

        <:action :let={ec}>
          <.link
            navigate={~p"/participant/#{ec.id}/delete"}
            data-confirm="Wirklich entfernen?"
          >
            Teilnehmer entfernen
          </.link>
        </:action>
      </.table>
    </div>
    """
  end
end
