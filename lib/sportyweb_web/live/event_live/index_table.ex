defmodule SportywebWeb.EventLive.IndexTableComponent do
  use SportywebWeb, :html
  import SportywebWeb.CommonHelper

  alias Sportyweb.Calendar
  alias Sportyweb.Calendar.Event

  attr :events, :list, required: true

  @impl true
  def render(assigns) do
    ~H"""
      <div>
        <.table id="events" rows={@events} row_click={&JS.navigate(~p"/events/#{&1}")}>
          <:col :let={event} label="Name">
            {format_string_field(event.name)}
          </:col>
          <:col :let={event} label="Ref.nr." >
            {format_string_field(event.reference_number)}
          </:col>
          <:col :let={event} label="Status" >
            {get_key_for_value(Event.get_valid_statuses(), event.status)}
          </:col>
          <:col :let={event} label="Description" >
            <div class="max-w-[200px] truncate overflow-hidden">
              {format_string_field(event.description)}
            </div>
          </:col>

          <:action :let={event}>
            <.link navigate={~p"/events/#{event}"}>Anzeigen</.link>
          </:action>
        </.table>
      </div>
    """
  end
end
