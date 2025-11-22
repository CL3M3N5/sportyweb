defmodule SportywebWeb.EventLive.CalendarComponent do
  use SportywebWeb, :live_component

  alias Phoenix.LiveView.JS
  alias Sportyweb.Calendar
  alias Sportyweb.Calendar.Event

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@page_title}
        <:actions>
          <.link navigate={~p"/clubs/#{@club}/events"}>
            <.button>
              Listenansicht
            </.button>
          </.link>

          <.link navigate={~p"/clubs/#{@club}/events/new"}>
            <.button>Veranstaltung erstellen</.button>
          </.link>
        </:actions>
      </.header>

      <.card>
        <.calendar
          id={@id || "interactive-calendar"}
          events={@events}
          on_event_click={
            JS.push("event_clicked")
            |> JS.show(to: "#event-details")
            |> JS.add_class("highlight", to: ".selected-event")
          }
          on_date_click={
            JS.push("date_clicked")
            |> JS.show(to: "#new-event-form")
            |> JS.focus(to: "#title")
          }
          on_month_change={
            JS.push("month_changed")
            |> JS.dispatch("calendar:month_changed")
          }
          options={%{
            view: "dayGridMonth",
            selectable: true,
            nowIndicator: true,
            height: "600px"
          }}
        />


      </.card>
    </div>
      """
  end
#  @impl true
#  def handle_params(params, _url, socket) do
#    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
#  end

#  @impl true
#  def handle_event("event_clicked", %{"id" => id}, socket) do
#    {:noreply,
#    push_navigate(socket,
#      to: ~p"/events/#{id}"
#    )}
#  end

#  @impl true
#  def handle_event("date_clicked", %{"date" => date}, socket), do: {:noreply, socket}

#  @impl true
#  def handle_event("month_changed", %{"month" => month, "year" => year}, socket), do: {:noreply, socket}





end
