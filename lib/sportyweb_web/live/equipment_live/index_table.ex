defmodule SportywebWeb.EquipmentLive.IndexTableComponent do
  use SportywebWeb, :html
  import SportywebWeb.CommonHelper

  attr :equipment, :list, required: true
  attr :event_id, :string, required: true

  def render(assigns) do
    ~H"""
    <div>
      <.table
        id="equipment"
        rows={@event.equipment}
        row_click={fn {_id, equipment} -> JS.navigate(~p"/equipment/#{equipment}") end}
      >
        <:col :let={{_id, equipment}} label="Name">
          {format_string_field(equipment.name)}
        </:col>
        <:col :let={{_id, equipment}} label="Ref.nr.">
          {format_string_field(equipment.reference_number)}
        </:col>
        <:col :let={{_id, equipment}} label="Beschreibung">
          <div class="max-w-[200px] truncate overflow-hidden">
            {format_string_field(equipment.description)}
          </div>
        </:col>

        <:action :let={{_id, equipment}}>
          <.link navigate={~p"/equipment/#{equipment}"}>Anzeigen</.link>
        </:action>
      </.table>

    </div>
    """
  end
end
