defmodule SportywebWeb.EventLive.GroupNew do
  use SportywebWeb, :live_view

  alias Sportyweb.Calendar
  alias Sportyweb.Organization

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.GroupLive.EventSelectComponent}
        id="group-select"
        title={@page_title}
        available_groups={@groups}
        group_object={@event}
        navigate={~p"/events/#{@event.id}"}
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :club_navigation_current_item, :calendar)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, %{"id" => id}) do
    # If the route behind this function should be more than a redirect in the future, put it in its own "Index"-LiveView!
    socket
    |> push_navigate(to: ~p"/events/#{id}")
  end


  # There is no "edit" action in this LiveView because that gets handled in the default SportywebWeb.GroupLive.NewEdit
  defp apply_action(socket, :new, %{"id" => id}) do
    event = Calendar.get_event!(id, [:club])
    club = event.club
    groups = Organization.list_groups_by_club(club.id)

    socket
    |> assign(
      :page_title,
      "Gruppe zur Veranstaltung hinzufügen"
    )
    |> assign(:groups, groups)
    |> assign(:event, event)
    |> assign(:club, event.club)

  end
end
