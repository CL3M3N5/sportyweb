defmodule SportywebWeb.EventWaitingListLive.IndexTableComponent do
  use SportywebWeb, :html
  import SportywebWeb.CommonHelper

  attr :waitinglist, :list, required: true
  attr :event_id, :string, required: true

  def render(assigns) do
    ~H"""
    <div>
      <.table id="waitinglist" rows={@waitinglist} row_click={&JS.navigate(~p"/contacts/#{&1.id}")}>
        <:col :let={ec} label="Name">
          {format_string_field(ec.name)}
        </:col>
        <:col :let={ec} label="Art">
          {get_key_for_value(Sportyweb.Personal.Contact.get_valid_types(), ec.type)}
        </:col>

        <:action :let={ec}>
          <.link
            navigate={~p"/events/#{@event_id}/waitinglist/#{ec.id}/delete"}
            data-confirm="Wirklich entfernen?"
          >
            Kontakt entfernen
          </.link>
        </:action>
      </.table>
    </div>
    """
  end
end
