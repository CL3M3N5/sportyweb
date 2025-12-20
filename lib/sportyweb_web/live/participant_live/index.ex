defmodule SportywebWeb.ParticipantLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.Repo
  alias Sportyweb.Calendar
  alias Sportyweb.Calendar.Event

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :contacts)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end


  defp apply_action(socket, :index_root, _params) do
    socket
    |> redirect(to: "/events")
  end


  defp apply_action(socket, :index, %{"id" => event_id}) do
    event = Sportyweb.Calendar.get_event!(event_id)
    event_participants = Sportyweb.Calendar.list_event_participants(event_id)

    socket
    |> assign(:page_title, "Teilnehmer")
    |> assign(:event, event)
    |> assign(:event_participants, event_participants)
  end
end
