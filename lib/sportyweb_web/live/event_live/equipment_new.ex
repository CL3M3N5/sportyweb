defmodule SportywebWeb.EventLive.EquipmentNew do
  use SportywebWeb, :live_view

  import Ecto.Query

  alias Sportyweb.Repo
  alias Sportyweb.Asset
  alias Sportyweb.Calendar

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.EquipmentLive.SelectComponent}
        id="equipment-select"
        title={@page_title}
        available_equipments={@equipment}
        equipment_object={@event}
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


  # There is no "edit" action in this LiveView because that gets handled in the default SportywebWeb.EquipmentLive.NewEdit
  defp apply_action(socket, :new, %{"id" => id}) do
    event = Calendar.get_event!(id, [:club])

    location_id =
      from(el in Sportyweb.Calendar.EventLocation,
      where: el.event_id == ^event.id,
      select: el.location_id )
      |> Repo.all()
      |> Enum.reject(&is_nil/1)

    if location_id == [] do
      socket
      |> put_flash(:error, "Für diese Veranstaltung ist kein Standort hinterlegt. Bitte zuerst einen Standort auswählen.")
      |> push_navigate(to: ~p"/events/#{event.id}")
    else
      location_equipments = Asset.list_equipments(location_id, [:location] )

      socket
      |> assign(
        :page_title,
        "Equiqment zur Veranstaltung hinzufügen"
      )
      |> assign(:equipment, location_equipments)
      |> assign(:event, event)
      |> assign(:club, event.club)
    end
  end
end
