defmodule SportywebWeb.LocationLive.EventIndexTableComponent do
  use SportywebWeb, :html
  import SportywebWeb.CommonHelper

  attr :locations, :list, required: true
  attr :event_id, :string, required: true

  def render(assigns) do
    ~H"""
    <div>
      <.table
        id="locations"
        rows={@locations}
        row_click={fn locations -> JS.navigate(~p"/locations/#{locations}") end}
      >
        <:col :let={locations} label="Name">
          {format_string_field(locations.name)}
        </:col>
        <:col :let={locations} label="Ref.nr.">
          {format_string_field(locations.reference_number)}
        </:col>
        <:col :let={locations} label="Beschreibung">
          <div class="max-w-[200px] truncate overflow-hidden">
            {format_string_field(locations.description)}
          </div>
        </:col>
        <:action :let={locations}>
          <.link
            navigate={~p"/events/#{@event_id}/locations/#{locations.id}/delete"}
            data-confirm="Wirklich entfernen?"
          >
            Standort entfernen
          </.link>
        </:action>
      </.table>

    </div>
    """
  end
end
