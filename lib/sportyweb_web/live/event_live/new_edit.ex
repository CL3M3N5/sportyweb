defmodule SportywebWeb.EventLive.NewEdit do
  use SportywebWeb, :live_view

  import Ecto.Query, only: [from: 2]
  alias Sportyweb.Repo
  alias Sportyweb.Asset.Location
  alias Sportyweb.Calendar
  alias Sportyweb.Calendar.Event
  alias Sportyweb.Calendar.EventLocation
  alias Sportyweb.Organization
  alias Sportyweb.Polymorphic.Email
  alias Sportyweb.Polymorphic.Note
  alias Sportyweb.Polymorphic.Phone
  alias Sportyweb.Polymorphic.PostalAddress
  alias Sportyweb.Personal.Contact

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

  # Hilfsfunktion um Kontaktoptionen für ein bestimmtes Club zu laden
  defp contact_options_for_club(club_id) do
    from(c in Contact,
      where: c.club_id == ^club_id,
      order_by: [asc: c.person_last_name, asc: c.person_first_name_1],
      select: {c.name, c.id}
    )
    |> Repo.all()
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    event =
      Calendar.get_event!(id, [:club, :emails, :phones, :postal_addresses, :notes, :event_locations, :participants])
    #contact_options = contact_options_for_club(event.club_id)

    socket
    |> assign(:page_title, "Veranstaltung bearbeiten")
    |> assign(:event, event)
    |> assign(:club, event.club)
  end

  defp apply_action(socket, :new, %{"club_id" => club_id}) do
    club = Organization.get_club!(club_id)
    venue_type = socket.assigns[:venue_type] || nil

    socket
    |> assign(:page_title, "Veranstaltung erstellen")
    |> assign(:event, %Event{
      club_id: club.id,
      club: club,
      venue_type: socket.assigns[:venue_type] || nil,
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
end
