defmodule SportywebWeb.EquipmentLive.EventSelectComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Asset
  alias Sportyweb.Asset.Equipment
  alias Sportyweb.Calendar
  alias Sportyweb.Calendar.Event

    @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header><%= @title || "Equipment zuordnen" %></.header>

      <%= if !@available_equipments || @available_equipments == [] do %>
        <.card>
          Für dieses Event sind derzeit keine Equipments verfügbar.
            <.cancel_button navigate={@navigate}>Abbrechen</.cancel_button>
        </.card>
      <% else %>
        <.card>
          <.simple_form
            for={@form}
            id="equipment-select-form"
            phx-target={@myself}
            phx-change="validate"
            phx-submit="save"
          >
            <.input
              type="select"
              name="selected_equipment_id"
              label="Vorhandenes Equipment auswählen"
              prompt="Bitte wählen"
              options={
                for e <- @available_equipments do
                  label =
                    if Map.get(e, :location) do
                      "#{e.name} - #{e.location.name}"
                    else
                      e.name
                    end

                  {label, e.id}
                end
              }
              value={@form.params["selected_equipment_id"] || ""}
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
    with %Event{} = event <- socket.assigns.equipment_object, equipment_id when is_binary(equipment_id) and equipment_id != "" <- Map.get(params, "selected_equipment_id") do

      case Calendar.create_event_equipment(event, %Equipment{id: equipment_id}) do
        {:ok, _join} ->
          {:noreply,
           socket
           |> put_flash(:info, "Equipment erfolgreich zugeordnet.")
           |> push_navigate(to: socket.assigns.navigate)}

        {:error, reason} ->
          {:noreply, put_flash(socket, :error, "Zuordnung fehlgeschlagen: #{inspect(reason)}")}
      end
    else
      _ ->
        {:noreply, put_flash(socket, :error, "Bitte wählen Sie ein Equipment aus.")}
    end
  end

  @impl true
  def handle_event("validate", %{"selected_equipment_id" => equipment_id}, socket) do
    case Asset.get_equipment!(equipment_id) do
      nil ->
        {:noreply,
        socket
        |> put_flash(:error, "Ungültiges Equipment ausgewählt.")
        |> assign(:valid_equipment, false)}

      equipment ->
        {:noreply,
        socket
        |> assign(:valid_equipment, true)
        |> assign(:selected_equipment, equipment)}
    end
  end
end
