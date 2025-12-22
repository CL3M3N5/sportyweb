defmodule SportywebWeb.ContactLive.Calendar do
  use SportywebWeb, :live_view

  alias Sportyweb.Calendar
  alias Sportyweb.Personal

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.EventLive.CalendarComponent}
        id="calendar"
        page_title={@page_title}
        club={@club}
        events={@events}
        eventfor={@eventfor}
        linktolistview={@linktolistview}
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :calendar)}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    require Logger
    contact =
      Personal.get_contact!(id, [
        :club
      ])
    club = contact.club

    today = Date.utc_today()
    month = socket.assigns[:view_month] ||  today.month
    year  = socket.assigns[:view_year]  ||  today.year

    start_date = Date.new!(year, month, 1)
    end_date   = Date.add(start_date, Date.days_in_month(start_date))
    raw_events = Calendar.list_events_by_contact(contact.id, start_date, end_date)
    Logger.debug("events in time period: #{length(raw_events)}")

    events =
      raw_events
      |> Enum.filter(& &1.start_date)
      |> Enum.flat_map(&Sportyweb.Calendar.get_calendar_event/1)
    Logger.debug("events sample: #{inspect(Enum.take(events, 3))}")

    {:noreply,
     socket
     |> assign(:page_title, "Veranstaltungskalender")
     |> assign(:eventfor, " #{contact.name}")
     |> assign(:linktolistview, ~p"/contacts/#{contact.id}")
     |> assign(:contact_id, id)
     |> assign(:contact, contact)
     |> assign(:club, club)
     |> assign(:view_month, month)
     |> assign(:view_year, year)
     |> assign(:events, events)
    }
  end

  @impl true
  def handle_event("event_clicked", %{"id" => id}, socket) do
    {:noreply,
     push_navigate(socket, to: ~p"/events/#{id}")}
  end

  @impl true
  def handle_event("month_changed", %{"month" => month, "year" => year}, socket) do
    require Logger
    contact_id = socket.assigns.contact_id

    start_date = Date.new!(year, month, 1)
    end_date   = Date.add(start_date, 90)

    raw_events = Calendar.list_events_by_contact(contact_id, start_date, end_date)
    Logger.debug("events in time period: #{length(raw_events)}")

    events =
      raw_events
      |> Enum.filter(& &1.start_date)
      |> Enum.flat_map(&Sportyweb.Calendar.get_calendar_event/1)
    Logger.debug("events sample: #{inspect(Enum.take(events, 3))}")

    {:noreply,
    socket

    |> assign(:view_month, month)
    |> assign(:view_year, year)
    |> assign(:events, events)
    }
  end
end
