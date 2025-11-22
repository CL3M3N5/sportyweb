defmodule SportywebWeb.EventLive.Calendar do
  use SportywebWeb, :live_view

  alias Sportyweb.Organization
  alias Sportyweb.Calendar
  alias Sportyweb.Calendar.Event

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.EventLive.CalendarComponent}
        id="club-calendar"
        page_title={@page_title}
        club={@club}
        events={@events}
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :calendar)}
  end

  @impl true
  def handle_params(%{"club_id" => club_id}, _url, socket) do
    club = Organization.get_club!(club_id, [:events])
    raw_events = Calendar.list_events(club_id)

    events =
      raw_events
      |> Enum.filter(& &1.start_date)
      |> Enum.map(&to_calendar_event/1)
      |> Enum.filter(& &1.start)

    {:noreply,
     socket
     |> assign(:page_title, "Veranstaltungskalender")
     |> assign(:club_id, club_id)
     |> assign(:club, club)
     |> assign(:events, events)}
  end

  @impl true
  def handle_event("event_clicked", %{"id" => id}, socket) do
    {:noreply,
     push_navigate(socket, to: ~p"/events/#{id}")}
  end

  @impl true
  def handle_event("month_changed", %{"month" => month, "year" => year}, socket) do
    {:noreply, socket}
  end

  defp to_calendar_event(%Event{} = event) do
    starttime = case {event.start_date, event.start_time} do
      {%Date{} = d, %Time{} = t} ->
        {:ok, ndt}  = NaiveDateTime.new(d, t)
        NaiveDateTime.to_iso8601(ndt)
      _ -> nil
    end
    endtime = case {event.end_date, event.end_time} do
      {%Date{} = d, %Time{} = t} ->
        {:ok, ndt}  = NaiveDateTime.new(d, t)
        NaiveDateTime.to_iso8601(ndt)
      _ -> nil
    end
    %{
      id: event.id,
      title: event.name,
      start: starttime,
      end: endtime
      }
   end



end
