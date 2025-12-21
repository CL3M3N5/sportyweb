defmodule SportywebWeb.EventLive.NewEdit do
  use SportywebWeb, :live_view

  alias Sportyweb.Asset.Location
  alias Sportyweb.Calendar
  alias Sportyweb.Calendar.Event
  alias Sportyweb.Organization
  alias Sportyweb.Polymorphic.Email
  alias Sportyweb.Polymorphic.Note
  alias Sportyweb.Polymorphic.Phone
  alias Sportyweb.Polymorphic.PostalAddress

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.EventLive.FormComponent}
        id={@event.id || :new}
        title={@page_title}
        action={@live_action}
        event={@event}
        navigate={if @event.id, do: ~p"/events/#{@event}", else: ~p"/clubs/#{@club}/events"}
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

  defp apply_action(socket, :edit, %{"id" => id}) do
    event =
      Calendar.get_event!(id, [:club, :emails, :phones, :postal_addresses, :notes, :event_locations, :participants])

    socket
    |> assign(:page_title, "Veranstaltung bearbeiten")
    |> assign(:event, event)
    |> assign(:club, event.club)
  end

  defp apply_action(socket, :new, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id)
    venue_type = socket.assigns[:venue_type] || nil
    group_id = socket.assigns[:group_id] || nil

    socket
    |> assign(:page_title, "Veranstaltung erstellen")
    |> assign(:event, %Event{
      club_id: club.id,
      club: club,
      venue_type: venue_type,
      group_id: group_id,
      event_locations: [%Location{}],
      postal_addresses: [%PostalAddress{}],
      emails: [%Email{}],
      phones: [%Phone{}],
      notes: [%Note{}]
    })
    |> assign(:club, club)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    event = Calendar.get_event!(id)
    {:ok, _} = Calendar.delete_event(event)

    {:noreply,
     socket
     |> put_flash(:info, "Veranstaltung erfolgreich gelöscht")
     |> push_navigate(to: "/clubs/#{event.club_id}/events")}
  end

  @impl true
  defp apply_action(socket, :deletedepartment, %{"department_id" => department_id, "id" => event_id}) do
    eventdepartment = Calendar.get_event_department(event_id, department_id)
    {:ok, _} = Calendar.delete_event_department(eventdepartment)

    socket
    |> put_flash(:info, "Abteilung erfolgreich vom Event entfernt")
    |> push_navigate(to: "/events/#{event_id}")
  end

  @impl true
  defp apply_action(socket, :deletegroup, %{"group_id" => group_id, "id" => event_id}) do
    eventgroup = Calendar.get_event_group(event_id, group_id)
    {:ok, _} = Calendar.delete_event_group(eventgroup)

    socket
    |> put_flash(:info, "Gruppe erfolgreich vom Event entfernt")
    |> push_navigate(to: "/events/#{event_id}")
  end

end
