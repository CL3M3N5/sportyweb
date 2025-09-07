defmodule SportywebWeb.EventLive.ContactFormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Repo
  alias Sportyweb.Calendar.EventContact

  @impl true
  def update(assigns, socket) do
    changeset = EventContact.changeset(%EventContact{}, %{event_id: assigns.event.id})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>
      <.card>
        <.simple_form
          for={@form}
          id="event-contact-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <.input
            field={@form[:contact_id]}
            type="select"
            label="Kontakt"
            options={@contact_options}
            prompt="Bitte auswählen"
            required
          />

          <:actions>
            <.button phx-disable-with="Speichern...">Speichern</.button>
            <.cancel_button navigate={@navigate}>Abbrechen</.cancel_button>
          </:actions>
        </.simple_form>
      </.card>
    </div>
    """
  end

  @impl true
  def handle_event("validate", %{"event_contact" => params}, socket) do
    params = Map.put(params, "event_id", socket.assigns.event.id)

    changeset =
      %EventContact{}
      |> EventContact.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"event_contact" => params}, socket) do
    params = Map.put(params, "event_id", socket.assigns.event.id)

    case Repo.insert(EventContact.changeset(%EventContact{}, params)) do
      {:ok, _ec} ->
        {:noreply,
         socket
         |> put_flash(:info, "Teilnehmer hinzugefügt.")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
