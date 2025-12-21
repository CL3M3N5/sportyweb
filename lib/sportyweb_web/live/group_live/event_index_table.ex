defmodule SportywebWeb.GroupLive.EventIndexTableComponent do
  use SportywebWeb, :html
  import SportywebWeb.CommonHelper

  attr :groups, :list, required: true
  attr :event_id, :string, required: true

  def render(assigns) do
    ~H"""
    <div>
      <.table
        id="groups"
        rows={@groups}
        row_click={fn groups -> JS.navigate(~p"/groups/#{groups}") end}
      >
        <:col :let={groups} label="Name">
          {format_string_field(groups.name)}
        </:col>
        <:col :let={groups} label="Ref.nr.">
          {format_string_field(groups.reference_number)}
        </:col>
        <:col :let={groups} label="Beschreibung">
          <div class="max-w-[200px] truncate overflow-hidden">
            {format_string_field(groups.description)}
          </div>
        </:col>
        <:col :let={groups} label="Erstellungsdatum">
          {format_date_field_dmy(groups.creation_date)}
        </:col>
        <:action :let={groups}>
          <.link
            navigate={~p"/events/#{@event_id}/groups/#{groups.id}/delete"}
            data-confirm="Wirklich entfernen?"
          >
            Gruppe entfernen
          </.link>
        </:action>
      </.table>

    </div>
    """
  end
end
