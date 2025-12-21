defmodule SportywebWeb.LocationLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Asset
  alias Sportyweb.Organization.Club
  alias Sportyweb.Calendar

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :assets)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    location =
      Asset.get_location!(id, [
        :club,
        :emails,
        :equipment,
        :notes,
        :phones,
        :postal_addresses,
        fees: :internal_events
      ])

    start_date = Date.utc_today()
    events = Calendar.list_events_by_location(location.id, start_date)

    {:noreply,
     socket
     |> assign(:page_title, "Standort: #{location.name}")
     |> assign(:location, location)
     |> assign(:club, location.club)
     |> assign(:events, events)
     |> stream(:equipment, location.equipment)
     }
  end
end
