defmodule SportywebWeb.DepartmentLive.EventSelectComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Organization
  alias Sportyweb.Organization.Department
  alias Sportyweb.Calendar
  alias Sportyweb.Calendar.Event

    @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header><%= @title || "Abteilung zuordnen" %></.header>

      <%= if !@available_departments || @available_departments == [] do %>
        <.card>
          Für dieses Event sind derzeit keine Abteilungen verfügbar.
          <:actions>
            <.cancel_button navigate={@navigate}>Abbrechen</.cancel_button>
          </:actions>
        </.card>
      <% else %>
        <.card>
          <.simple_form
            for={@form}
            id="department-select-form"
            phx-target={@myself}
            phx-change="validate"
            phx-submit="save"
          >
            <.input
              type="select"
              name="selected_department_id"
              label="Vorhandene Abteilung auswählen"
              prompt="Bitte wählen"
              options={
                for e <- @available_departments do
                  label =
                    if Map.get(e, :location) do
                      "#{e.name} - #{e.location.name}"
                    else
                      e.name
                    end

                  {label, e.id}
                end
              }
              value={@form.params["selected_department_id"] || ""}
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
    with %Event{} = event <- socket.assigns.department_object, departments_id when is_binary(departments_id) and departments_id != "" <- Map.get(params, "selected_department_id") do

      case Calendar.create_event_department(event, %Department{id: departments_id}) do
        {:ok, _join} ->
          {:noreply,
           socket
           |> put_flash(:info, "Abteilung erfolgreich zugeordnet.")
           |> push_navigate(to: socket.assigns.navigate)}

        {:error, reason} ->
          {:noreply, put_flash(socket, :error, "Zuordnung fehlgeschlagen: #{inspect(reason)}")}
      end
    else
      _ ->
        {:noreply, put_flash(socket, :error, "Bitte wählen Sie eine Abteilung aus.")}
    end
  end

  @impl true
  def handle_event("validate", %{"selected_department_id" => department_id}, socket) do
    case Organization.get_department!(department_id) do
      nil ->
        {:noreply,
        socket
        |> put_flash(:error, "Ungültige Abteilung ausgewählt.")
        |> assign(:valid_department, false)}

      department ->
        {:noreply,
        socket
        |> assign(:valid_department, true)
        |> assign(:selected_department, department)}
    end
  end
end
