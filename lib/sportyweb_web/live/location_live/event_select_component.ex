defmodule SportywebWeb.LocationLive.EventSelectComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Asset
  alias Sportyweb.Asset.Location
  alias Sportyweb.Calendar
  alias Sportyweb.Calendar.Event

    @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header><%= @title || "Standort zuordnen" %></.header>

      <%= if !@available_locations || @available_locations == [] do %>
        <.card>
          Für dieses Event sind derzeit keine Standorte verfügbar.
          <:actions>
            <.cancel_button navigate={@navigate}>Abbrechen</.cancel_button>
          </:actions>
        </.card>
      <% else %>
        <.card>
          <.simple_form
            for={@form}
            id="location-select-form"
            phx-target={@myself}
            phx-change="validate"
            phx-submit="save"
          >
            <.input
              type="select"
              name="selected_location_id"
              label="Vorhandenen Standort auswählen"
              prompt="Bitte wählen"
              options={
                for e <- @available_locations do
                  label =
                    if Map.get(e, :location) do
                      "#{e.name} - #{e.location.name}"
                    else
                      e.name
                    end

                  {label, e.id}
                end
              }
              value={@form.params["selected_location_id"] || ""}
            />

            <:actions>
                <.button type="submit" phx-disable-with="zuordnen...">Zuordnung speichern</.button>
                <.cancel_button navigate={@navigate}>Abbrechen</.cancel_button>
            </:actions>
          </.simple_form>
        </.card>
      <% end %>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(%{})
     end)}
  end

 @impl true
  def handle_event("save", params, socket) do
    with %Event{} = event <- socket.assigns.location_object, location_id when is_binary(location_id) and location_id != "" <- Map.get(params, "selected_location_id") do

      case Calendar.create_event_location(event, %Location{id: location_id}) do
        {:ok, _join} ->
          {:noreply,
           socket
           |> put_flash(:info, "Standort erfolgreich zugeordnet.")
           |> push_navigate(to: socket.assigns.navigate)}

        {:error, reason} ->
          {:noreply, put_flash(socket, :error, "Zuordnung fehlgeschlagen: #{inspect(reason)}")}
      end
    else
      _ ->
        {:noreply, put_flash(socket, :error, "Bitte wählen Sie einen Standort aus.")}
    end
  end

  @impl true
  def handle_event("validate", %{"selected_location_id" => location_id}, socket) do
    case Asset.get_location!(location_id) do
      nil ->
        {:noreply,
        socket
        |> put_flash(:error, "Ungültigen Standort ausgewählt.")
        |> assign(:valid_location, false)}

      location ->
        {:noreply,
        socket
        |> assign(:valid_location, true)
        |> assign(:selected_location, location)}
    end
  end
end
