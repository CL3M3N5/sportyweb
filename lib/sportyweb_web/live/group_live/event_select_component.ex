defmodule SportywebWeb.GroupLive.EventSelectComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Organization
  alias Sportyweb.Organization.Group
  alias Sportyweb.Calendar
  alias Sportyweb.Calendar.Event

    @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header><%= @title || "Gruppe zuordnen" %></.header>

      <%= if !@available_groups || @available_groups == [] do %>
        <.card>
          Für dieses Event sind derzeit keine Gruppen verfügbar.
          <:actions>
            <.cancel_button navigate={@navigate}>Abbrechen</.cancel_button>
          </:actions>
        </.card>
      <% else %>
        <.card>
          <.simple_form
            for={@form}
            id="group-select-form"
            phx-target={@myself}
            phx-change="validate"
            phx-submit="save"
          >
            <.input
              type="select"
              name="selected_group_id"
              label="Vorhandene Gruppe auswählen"
              prompt="Bitte wählen"
              options={
                for e <- @available_groups do
                  label =
                    if Map.get(e, :location) do
                      "#{e.name} - #{e.location.name}"
                    else
                      e.name
                    end

                  {label, e.id}
                end
              }
              value={@form.params["selected_group_id"] || ""}
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
    with %Event{} = event <- socket.assigns.group_object, groups_id when is_binary(groups_id) and groups_id != "" <- Map.get(params, "selected_group_id") do

      case Calendar.create_event_group(event, %Group{id: groups_id}) do
        {:ok, _join} ->
          {:noreply,
           socket
           |> put_flash(:info, "Gruppe erfolgreich zugeordnet.")
           |> push_navigate(to: socket.assigns.navigate)}

        {:error, reason} ->
          {:noreply, put_flash(socket, :error, "Zuordnung fehlgeschlagen: #{inspect(reason)}")}
      end
    else
      _ ->
        {:noreply, put_flash(socket, :error, "Bitte wählen Sie eine Gruppe aus.")}
    end
  end

  @impl true
  def handle_event("validate", %{"selected_group_id" => group_id}, socket) do
    case Organization.get_group!(group_id) do
      nil ->
        {:noreply,
        socket
        |> put_flash(:error, "Ungültige Gruppe ausgewählt.")
        |> assign(:valid_group, false)}

      group ->
        {:noreply,
        socket
        |> assign(:valid_group, true)
        |> assign(:selected_group, group)}
    end
  end
end
