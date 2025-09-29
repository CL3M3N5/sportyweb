defmodule SportywebWeb.ParticipantLive.NewEdit do
  use SportywebWeb, :live_view

  import Ecto.Query, only: [from: 2]
  alias Sportyweb.Repo
  alias Sportyweb.Calendar.{Event, EventContact}
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
  def mount(_params, _session, socket), do: {:ok, socket}

  @impl true
  def handle_params(%{"id" => event_id}, _uri, socket) do
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

    {:noreply,
     socket
     |> assign(:page_title, "Teilnehmer hinzufügen")
     |> assign(:event, event)
     |> assign(:contact_options, contact_options)}
  end
end
