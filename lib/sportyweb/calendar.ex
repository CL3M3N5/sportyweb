defmodule Sportyweb.Calendar do
  @moduledoc """
  The Calendar context.
  """

  import Ecto.Query, warn: false
  alias Sportyweb.Repo

  alias Sportyweb.Calendar.Event
  alias Sportyweb.Calendar.EventFee
  alias Sportyweb.Calendar.EventContact
  alias Sportyweb.Calendar.EventDepartment
  alias Sportyweb.Finance.Fee
  alias Sportyweb.Asset
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Organization

  @doc """
  Returns a clubs list of events.

  ## Examples

      iex> list_events()
      [%Event{}, ...]

  """
  def list_events(club_id) do
    query = from(e in Event, where: e.club_id == ^club_id)
    Repo.all(query)
  end

  @doc """
  Returns a clubs list of events. Preloads associations.

  ## Examples

      iex> list_events(1, [:club])
      [%Event{}, ...]

  """
  def list_events(club_id, preloads) do
    Repo.preload(list_events(club_id), preloads)
  end

    @doc """
  Returns a clubs list of events between start time and end time.

  ## Examples

      iex> list_events(club_id, view_start_time, view_end_time)
      [%Event{}, ...]

  """
  def list_events(club_id, view_start_time, view_end_time) do
    query = from(e in Event,
    where: e.club_id == ^club_id,
    where: e.end_date >= ^view_start_time,
    where: e.start_date <= ^view_end_time,
    where: not is_nil(e.start_date),
    where: not is_nil(e.end_date)
    )

    Repo.all(query)
  end

   @doc """
  Returns a location list of events between start time and end time.

  ## Examples

      iex> list_events_by_location(location_id, view_start_time, view_end_time)
      [%Event{}, ...]

  """
  def list_events_by_location(location_id, view_start_time, view_end_time) do
    query = from(e in Event,
    join: el in Sportyweb.Calendar.EventLocation,
    on: el.event_id == e.id,
    where: el.location_id == ^location_id,
    where: e.end_date >= ^view_start_time,
    where: e.start_date <= ^view_end_time,
    where: not is_nil(e.start_date),
    where: not is_nil(e.end_date),
    select: e
    )

    Repo.all(query)
  end

  @doc """
  Returns a location list of events starting from the start time.

  ## Examples

      iex> list_events_by_location(location_id, view_start_time)
      [%Event{}, ...]

  """
  def list_events_by_location(location_id, view_start_time) do
    query = from(e in Event,
    join: el in Sportyweb.Calendar.EventLocation,
    on: el.event_id == e.id,
    where: el.location_id == ^location_id,
    where: e.end_date >= ^view_start_time,
    where: not is_nil(e.start_date),
    where: not is_nil(e.end_date),
    select: e
    )

    Repo.all(query)
  end


  @doc """
  Returns a  list of events between start time and end time by equipment.

  ## Examples

      iex> list_events_by_equipment(equipment_id, view_start_time, view_end_time)
      [%Event{}, ...]

  """
  def list_events_by_equipment(equipment_id, view_start_time, view_end_time) do
    query = from(e in Event,
    join: el in Sportyweb.Calendar.EventEquipment,
    on: el.event_id == e.id,
    where: el.equipment_id == ^equipment_id,
    where: e.end_date >= ^view_start_time,
    where: e.start_date <= ^view_end_time,
    where: not is_nil(e.start_date),
    where: not is_nil(e.end_date),
    select: e
    )

    Repo.all(query)
  end

  @doc """
  Returns a location list of events starting from the start time.

  ## Examples

      iex> list_events_by_equipment(equipment_id, view_start_time)
      [%Event{}, ...]

  """
  def list_events_by_equipment(equipment_id, view_start_time) do
    query = from(e in Event,
    join: el in Sportyweb.Calendar.EventEquipment,
    on: el.event_id == e.id,
    where: el.equipment_id == ^equipment_id,
    where: e.end_date >= ^view_start_time,
    where: not is_nil(e.start_date),
    where: not is_nil(e.end_date),
    select: e
    )

    Repo.all(query)
  end

  @doc """
  Returns a  list of events between start time and end time by department.

  ## Examples

      iex> list_events_by_department(department_id, view_start_time, view_end_time)
      [%Event{}, ...]

  """
  def list_events_by_department(department_id, view_start_time, view_end_time) do
    query = from(e in Event,
    where: e.department_id == ^department_id,
    where: e.end_date >= ^view_start_time,
    where: e.start_date <= ^view_end_time,
    where: not is_nil(e.start_date),
    where: not is_nil(e.end_date),
    select: e
    )

    Repo.all(query)
  end

    @doc """
  Returns a  list of events between start time and end time by group.

  ## Examples

      iex> list_events_by_group(group_id, view_start_time, view_end_time)
      [%Event{}, ...]

  """
  def list_events_by_group(group_id, view_start_time, view_end_time) do
    query = from(e in Event,
    where: e.group_id == ^group_id,
    where: e.end_date >= ^view_start_time,
    where: e.start_date <= ^view_end_time,
    where: not is_nil(e.start_date),
    where: not is_nil(e.end_date),
    select: e
    )

    Repo.all(query)
  end

  @doc """
  Gets a single event.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event!(123)
      %Event{}

      iex> get_event!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event!(id), do: Repo.get!(Event, id)

  @doc """
  Gets a single event. Preloads associations.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event!(123, [:club])
      %Event{}

      iex> get_event!(456, [:club])
      ** (Ecto.NoResultsError)

  """
  def get_event!(id, preloads) do
    Event
    |> Repo.get!(id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a event.

  ## Examples

      iex> create_event(%{field: value})
      {:ok, %Event{}}

      iex> create_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event(attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a event.

  ## Examples

      iex> update_event(event, %{field: new_value})
      {:ok, %Event{}}

      iex> update_event(event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a event.

  ## Examples

      iex> delete_event(event)
      {:ok, %Event{}}

      iex> delete_event(event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event(%Event{} = event) do
    Repo.delete(event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event changes.

  ## Examples

      iex> change_event(event)
      %Ecto.Changeset{data: %Event{}}

  """
  def change_event(%Event{} = event, attrs \\ %{}) do
    Event.changeset(event, attrs)
  end

  @doc """
  Creates a event_fee (many_to_many).

  ## Examples

      iex> create_event_fee(event, fee)
      {:ok, %EventFee{}}

      iex> create_event_fee(event, fee)
      {:error, %Ecto.Changeset{}}

  """
  def create_event_fee(%Event{} = event, %Fee{} = fee) do
    Repo.insert(%EventFee{
      event_id: event.id,
      fee_id: fee.id
    })
  end

  @doc """
  Gets a single event with participants (contacts).
  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event_with_participants!(123)
      %Event{}

  """

  def get_event_with_participants!(id) do
    Event
    |> Repo.get!(id)
    |> Repo.preload([:organizers, :participants, :waitinglist])
  end

  @doc """
  Get a conact from an event.

  ## Examples

      iex> get_event_contact(event_id, contact_id, role)
      {:ok, %Event{}}

      iex> get_event_contact(event_id, contact_id, role)
      {:error, %Ecto.Changeset{}}

  """
  def get_event_contact!(event_id, contact_id, role \\ "participant") do
    Repo.get_by!(EventContact,
      event_id: event_id,
      contact_id: contact_id,
      role: role
    )
  end

  @doc """
  Deletes a conact from an event.

  ## Examples

      iex> delete_event_contact(EventContact)
      {:ok, %Event{}}

      iex> delete_event_contact(EventContact)
      {:error, %Ecto.Changeset{}}

  """

  def delete_event_contact(%EventContact{} = ec) do
    Repo.delete(ec)
  end

  @doc """
  Get a conact from an event.

  ## Examples

      iex> get_event_contact(event_id, department_id)
      {:ok, %Event{}}

      iex> get_event_contact(event_id, department_id)
      {:error, %Ecto.Changeset{}}

  """
  def get_event_department(event_id, department_id) do
    Repo.get_by(EventDepartment,
      event_id: event_id,
      department_id: department_id
    )
  end

    @doc """
  Deletes a department from an event.

  ## Examples

      iex> delete_event_department(EventDepartment)
      {:ok, %Event{}}

      iex> delete_event_department(EventDepartment)
      {:error, %Ecto.Changeset{}}

  """

  def delete_event_department(%EventDepartment{} = ec) do
    Repo.delete(ec)
  end


  @doc """
  Creates a event_equipment (many_to_many).
  ## Examples

      iex> create_event_equipment(event, equipment)
      {:ok, %EventEquipment{}}

      iex> create_event_equipment(event, equipment)
      {:error, %Ecto.Changeset{}}

  """

  def create_event_equipment(%Event{} = event, %Asset.Equipment{} = equipment) do
    Repo.insert(%Sportyweb.Calendar.EventEquipment{
      event_id: event.id,
      equipment_id: equipment.id
    })
  end

  @doc """
  Creates a event_department (many_to_many).
  ## Examples

      iex> create_event_department(event, department)
      {:ok, %EventDepartment{}}

      iex> create_event_department(event, department)
      {:error, %Ecto.Changeset{}}

  """

  def create_event_department(%Event{} = event, %Organization.Department{} = department) do
    Repo.insert(%Sportyweb.Calendar.EventDepartment{
      event_id: event.id,
      department_id: department.id
    })
  end

  @doc """
  Get a list of appointment of a event for the calendar view.
  ## Examples

      iex> get_calendar_event(event)
      {:ok, %Event{}}

  """

  def get_calendar_event(%Event{} = event) do
    require Logger

   if event.period_type == "recurring" do
      {:ok, end_datetime} = NaiveDateTime.new(event.end_date, event.end_time)
      {:ok, start_datetime} = NaiveDateTime.new(event.start_date, event.start_time)

      cbase = Cocktail.Schedule.new(start_datetime)

      schedule =
        case event.occurrence_type do
          "daily" ->
            Cocktail.Schedule.add_recurrence_rule(cbase, :daily, until: end_datetime)

          "weekly" ->
            days = event.recurrence_weekdays
              |> List.wrap()
              |> Enum.map(&Sportyweb.Calendar.Event.weekday_str_to_atom/1)
              |> Enum.reject(&is_nil/1)
            Logger.debug("#{inspect(days)}")

            Cocktail.Schedule.add_recurrence_rule(cbase, :weekly, days: days, until: end_datetime)

          "monthly" ->

              case event.recurrence_monthly_type do
                "day_of_month" ->
                  day = event.recurrence_monthly_day
                  Logger.debug("monthly day_of_month #{inspect(day)}")
                  if is_integer(day) do
                    Cocktail.Schedule.add_recurrence_rule(cbase, :monthly, Keyword.merge([days_of_month: [day]], until: end_datetime))
                  else
                    Logger.debug("Keine Tage vorhanden #{inspect(event.recurrence_monthly_day)}")
                    nil
                  end
                "weekday_of_month" ->
                  nil

                _ -> nil
              end

          "yearly" ->
            # "Cocktail", the date recurrence library in use doesn't natively support a yearly frequency.
            # Therefore, the interval might have to be converted from year to month via a multiplication by 12.
            Cocktail.Schedule.add_recurrence_rule(cbase, :monthly, interval: 12,  until: end_datetime)
          _ ->
            nil
        end

      s =
        case Time.to_seconds_after_midnight(event.start_time) do
          sec when is_integer(sec) -> sec
          {sec, _} when is_integer(sec) -> sec
        end
      e =
        case Time.to_seconds_after_midnight(event.end_time) do
          sec when is_integer(sec) -> sec
          {sec, _} when is_integer(sec) -> sec
        end


      # Convert the occurrences to Date and filter them, so they only include dates in the range from start_date to end_date.
      # Convert the stream to a list at the end, to make it easier to work with.
      Cocktail.Schedule.occurrences(schedule)
      |> Stream.filter(fn %NaiveDateTime{} = start_at ->
        d = NaiveDateTime.to_date(start_at)
        Date.compare(d, event.start_date) != :lt and Date.compare(d, event.end_date) != :gt
      end)
      |> Stream.map(fn %NaiveDateTime{} = start_at ->
        end_at = NaiveDateTime.add(start_at, e - s, :second)
        %{
          id: event.id,
          title: event.name,
          start: NaiveDateTime.to_iso8601(start_at),
          end: NaiveDateTime.to_iso8601(end_at)
        }
      end)
    |> Enum.to_list()


    else
      starttime = case {event.start_date, event.start_time} do
        {%Date{} = d, %Time{} = t} ->
          {:ok, ndt}  = NaiveDateTime.new(d, t)
          NaiveDateTime.to_iso8601(ndt)
        _ -> nil
      end
      endtime = case {event.end_date, event.end_time} do
        {%Date{} = d, %Time{} = t} ->
          {:ok, ndt}  = NaiveDateTime.new(d, t)
          NaiveDateTime.to_iso8601(ndt)
        _ -> nil
      end
      [
        %{
          id: event.id,
          title: event.name,
          start: starttime,
          end: endtime
        }
      ]
    end
  end

  @doc """
  Get a list of 30 participants of an event.
  ## Examples

      iex> list_event_participants_first30(event)
      {:ok, %Event{}}

  """
  def list_event_participants_first30(event_id) do

    Repo.all(
      from c in Contact,
      join: ec in EventContact,
      on: ec.contact_id == c.id,
      where: ec.event_id == ^event_id and ec.role == "participant",
      limit: 30,
      select: c
    )
  end

  @doc """
  Get a list of all participants of an event.
  ## Examples

      iex> list_event_participants(event)
      {:ok, %Event{}}

  """
  def list_event_participants(event_id) do

    Repo.all(
      from c in Contact,
      join: ec in EventContact,
      on: ec.contact_id == c.id,
      where: ec.event_id == ^event_id and ec.role == "participant",
      select: c
    )
  end

  @doc """
  Get the number of all participants of an event.
  ## Examples

      iex> count_event_participants(event)
      {:ok, %Event{}}

  """
  def count_event_participants(event_id) do
    Repo.one(
      from ec in EventContact,
      where: ec.event_id == ^event_id and ec.role == "participant",
      select: count(ec.id)
    )
  end
end
