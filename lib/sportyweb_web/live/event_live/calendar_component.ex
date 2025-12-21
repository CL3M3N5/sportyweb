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
          <.link navigate={@linktolistview}>
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
        <div class="text-2xl text-wrap">Termine für <strong><%= @eventfor %></strong></div>
        <.calendar
          id={"calendar"}
          phx-update="ignore"
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
          on_month_change={JS.push("month_changed")}
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
end
