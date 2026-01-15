defmodule SportywebWeb.EventLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Calendar
  alias Sportyweb.Calendar.Event

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :calendar)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    event =
      Calendar.get_event!(id, [
        :club,
        :emails,
        :notes,
        :phones,
        :postal_addresses,
        :locations,
        :organizers,
        :waitinglist,
        :departments,
        :groups,
        :equipment,
        equipment: :fees,
        locations: :fees,
        fees: :internal_events
      ])

    participants_preview = Calendar.list_event_participants_first30(event.id)
    participants_count   = Calendar.count_event_participants(event.id)


    {:noreply,
     socket
     |> assign(:page_title, "Veranstaltung: #{event.name}")
     |> assign(:event, event)
     |> assign(:club, event.club)
     |> assign(:participants_preview, participants_preview)
     |> assign(:participants_count, participants_count)}
  end
end
