defmodule SportywebWeb.DepartmentLive.EventIndexTableComponent do
  use SportywebWeb, :html
  import SportywebWeb.CommonHelper
  alias Sportyweb.Organization.Department

  attr :department, :list, required: true
  attr :event_id, :string, required: true

  def render(assigns) do
    ~H"""
    <div>
      <.table
        id="departments"
        rows={@departments}
        row_click={fn departments -> JS.navigate(~p"/departments/#{departments}") end}
      >
        <:col :let={departments} label="Name">
          {format_string_field(departments.name)}
        </:col>
        <:col :let={departments} label="Ref.nr.">
          {format_string_field(departments.reference_number)}
        </:col>
        <:col :let={departments} label="Beschreibung">
          <div class="max-w-[200px] truncate overflow-hidden">
            {format_string_field(departments.description)}
          </div>
        </:col>
        <:col :let={departments} label="Erstellungsdatum">
          {format_date_field_dmy(departments.creation_date)}
        </:col>
        <:action :let={departments}>
          <.link
            navigate={~p"/events/#{@event_id}/departments/#{departments.id}/delete"}
            data-confirm="Wirklich entfernen?"
          >
            Abteilung entfernen
          </.link>
        </:action>
      </.table>

    </div>
    """
  end
end
