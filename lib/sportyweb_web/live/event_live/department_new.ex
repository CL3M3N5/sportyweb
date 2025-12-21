defmodule SportywebWeb.EventLive.DepartmentNew do
  use SportywebWeb, :live_view

  alias Sportyweb.Calendar
  alias Sportyweb.Organization

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.DepartmentLive.EventSelectComponent}
        id="department-select"
        title={@page_title}
        available_departments={@departments}
        department_object={@event}
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


  # There is no "edit" action in this LiveView because that gets handled in the default SportywebWeb.departmentLive.NewEdit
  defp apply_action(socket, :new, %{"id" => id}) do
    event = Calendar.get_event!(id, [:club])
    club = event.club
    club_id = club.id

    departments = Organization.list_departments(club_id)

    socket
    |> assign(
      :page_title,
      "Abteilung zur Veranstaltung hinzufügen"
    )
    |> assign(:departments, departments)
    |> assign(:event, event)
    |> assign(:club, event.club)

  end
end
