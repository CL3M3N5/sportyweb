defmodule SportywebWeb.EquipmentLive.IndexTableComponent do
  use SportywebWeb, :html
  import SportywebWeb.CommonHelper
  alias Sportyweb.Finance.Fee

  attr :equipment, :list, required: true
  attr :event_id, :string, required: true

  def render(assigns) do
    ~H"""
    <div>
      <.table
        id="equipment"
        rows={@equipment}
        row_click={fn equipment -> JS.navigate(~p"/equipment/#{equipment.id}") end}
      >
        <:col :let={ equipment} label="Name">
          {format_string_field(equipment.name)}
        </:col>
        <:col :let={equipment} label="Ref.nr.">
          {format_string_field(equipment.reference_number)}
        </:col>
        <:col :let={equipment} label="Beschreibung">
          <div class="max-w-[200px] truncate overflow-hidden">
            {format_string_field(equipment.description)}
          </div>
        </:col>
        <:col :let={equipment} label="Grundbetrag">
          <%= for {fee, idx} <- Enum.with_index(equipment.fees) do %>
            <%= if idx > 0, do: ", " %>
            <%= Money.to_string!(fee.amount, locale: "de") %>
          <% end %>
        </:col>
        <:col :let={equipment} label="Einmalzahlung">
          <%= for {fee, idx} <- Enum.with_index(equipment.fees) do %>
            <%= if idx > 0, do: ", " %>
            <%= Money.to_string!(fee.amount_one_time, locale: "de") %>
          <% end %>
        </:col>
        <:action :let={equipment}>
          <.link navigate={~p"/equipment/#{equipment.id}"}>Anzeigen</.link>
        </:action>
      </.table>

    </div>
    """
  end
end
