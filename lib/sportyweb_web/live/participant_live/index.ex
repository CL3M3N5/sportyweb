defmodule SportywebWeb.ParticipantLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.Calendar.Event
  alias Sportyweb.Calendar.EventContact
  alias Sportyweb.Personal.Contact

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :contacts)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp load_event_with_participants(event_id) do
    Event
    |> Repo.get!(event_id)
    |> Repo.preload(event_contacts: [:contact])
  end

  defp apply_action(socket, :index_root, _params) do
    socket
    |> redirect(to: "/events")
  end


  defp apply_action(socket, :index, %{"id" => event_id}) do
    event = load_event_with_participants(event_id)

    socket
    |> assign(:page_title, "Teilnehmer")
    |> assign(:event, event)
    |> assign(:event_contacts, event.event_contacts)
    |> assign(:contact_options, [])
  end
end
