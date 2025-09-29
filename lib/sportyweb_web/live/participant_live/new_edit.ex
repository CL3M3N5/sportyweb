defmodule SportywebWeb.ParticipantLive.NewEdit do
  use SportywebWeb, :live_view

  import Ecto.Query, only: [from: 2]
  alias Sportyweb.Repo
  alias Sportyweb.Calendar.Event
  alias Sportyweb.Calendar.EventContact
  alias Sportyweb.Personal.Contact

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={SportywebWeb.ParticipantLive.FormComponent}
        id="contact-form"
        title={@page_title}
        event={@event}
        contact_options={@contact_options}
        navigate={~p"/events/#{@event.id}/"}
      />
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :event_navigation_current_item, :calendar)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, %{"id" => event_id}) do
    event = Repo.get!(Event, event_id)

    already_ids =
      from(ec in EventContact, where: ec.event_id == ^event.id, select: ec.contact_id)
      |> Repo.all()

    contact_options =
      from(c in Contact,
        where: c.club_id == ^event.club_id and c.id not in ^already_ids,
        order_by: [asc: c.person_last_name, asc: c.person_first_name_1],
        select: {c.name, c.id}  # simpel: Label = gespeicherter Name
      )
      |> Repo.all()

    socket
    |> assign(:page_title, "Teilnehmer hinzufügen")
    |> assign(:event, event)
    |> assign(:contact_options, contact_options)
  end

  defp apply_action(socket, :delete, %{"event_contact_id" => ec_id} ) do
    eventcontactid = Repo.get!(EventContact, ec_id)
    {:ok, _} = Repo.delete(eventcontactid)
    event_id = eventcontactid.event_id

    socket
    |> put_flash(:info, "Teilnehmer erfolgreich gelöscht")
    |> push_navigate(to: "/events/#{event_id}")
  end
end
