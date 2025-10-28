defmodule Sportyweb.Calendar.Event do
  use Ecto.Schema
  import Ecto.Changeset
  import SportywebWeb.CommonValidations

  alias Sportyweb.Asset.Equipment
  alias Sportyweb.Calendar.EventDepartment
  alias Sportyweb.Calendar.EventEmail
  alias Sportyweb.Calendar.EventEquipment
  alias Sportyweb.Calendar.EventFee
  alias Sportyweb.Calendar.EventGroup
  alias Sportyweb.Calendar.EventNote
  alias Sportyweb.Calendar.EventPhone
  alias Sportyweb.Calendar.EventPostalAddress
  alias Sportyweb.Calendar.EventLocation
  alias Sportyweb.Calendar.EventContact
  alias Sportyweb.Finance.Fee
  alias Sportyweb.Personal.Contact
  alias Sportyweb.Organization.Club
  alias Sportyweb.Organization.Department
  alias Sportyweb.Organization.Group
  alias Sportyweb.Polymorphic.Email
  alias Sportyweb.Polymorphic.Note
  alias Sportyweb.Polymorphic.Phone
  alias Sportyweb.Polymorphic.PostalAddress


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "events" do
    belongs_to :club, Club
    has_many :event_participants, EventContact, where: [role: "participant"], on_delete: :delete_all
    has_many :event_organizers,  EventContact, where: [role: "organizer"], on_delete: :delete_all
    has_many :participants, through: [:event_participants, :contact]
    has_many :organizers, through: [:event_organizers, :contact]
    has_many :event_locations, EventLocation, on_replace: :delete, on_delete: :delete_all
    has_many :locations, through: [:event_locations, :location]
    many_to_many :contacts, Contact, join_through: EventContact
    many_to_many :departments, Department, join_through: EventDepartment
    many_to_many :emails, Email, join_through: EventEmail
    many_to_many :equipment, Equipment, join_through: EventEquipment
    many_to_many :fees, Fee, join_through: EventFee
    many_to_many :groups, Group, join_through: EventGroup
    many_to_many :notes, Note, join_through: EventNote
    many_to_many :phones, Phone, join_through: EventPhone
    many_to_many :postal_addresses, PostalAddress, join_through: EventPostalAddress


    field :name, :string, default: ""
    field :reference_number, :string, default: ""
    field :status, :string, default: ""
    field :description, :string, default: ""
    field :minimum_participants, :integer, default: nil
    field :maximum_participants, :integer, default: nil
    field :minimum_age_in_years, :integer, default: nil
    field :maximum_age_in_years, :integer, default: nil
    field :venue_type, :string, default: ""
    field :venue_description, :string, default: ""
    field :period_type, :string, default: "single"
    field :occurrence_type, :string, default: ""
    field :recurrence_rule, :string, default: ""
    field :recurrence_exceptions, {:array, :utc_datetime}, default: []
    field :recurrence_weekdays, {:array, :string}, default: []
    field :recurrence_monthly_type, :string, default: ""
    field :recurrence_monthly_day, :integer, default: nil
    field :recurrence_monthly_nth, :integer, default: nil
    field :recurrence_monthly_weekday, :string, default: ""
    field :start_date, :date , default: nil
    field :end_date, :date, default: nil
    field :start_time, :time, default: nil
    field :end_time, :time, default: nil

    timestamps(type: :utc_datetime)
  end

  def get_valid_statuses do
    [
      [key: "Entwurf", value: "draft"],
      [key: "Freigegeben", value: "public"],
      [key: "Abgesagt", value: "cancelled"]
    ]
  end

  def get_valid_venue_types do
    [
      [key: "Keine Angabe", value: "no_info"],
      [key: "Standort des Clubs", value: "location"],
      [key: "Adresse", value: "postal_address"],
      [key: "Freifeld", value: "free_form"]
    ]
  end

  def get_valid_period_types do
    [
      [key: "Einzeltermin", value: "single"],
      [key: "Wiederkehrend", value: "recurring"]
    ]
  end

  def get_valid_recurrence_types do
    [
      [key: "täglich", value: "daily"],
      [key: "wöchentlich", value: "weekly"],
      [key: "monatlich", value: "monthly"],
      [key: "jährlich", value: "yearly"]
    ]
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(
      attrs,
      [
        :club_id,
        :name,
        :reference_number,
        :status,
        :description,
        :minimum_participants,
        :maximum_participants,
        :minimum_age_in_years,
        :maximum_age_in_years,
        :venue_type,
        :venue_description,
        :period_type,
        :occurrence_type,
        :recurrence_rule,
        :recurrence_exceptions,
        :recurrence_weekdays,
        :recurrence_monthly_type,
        :recurrence_monthly_day,
        :recurrence_monthly_nth,
        :recurrence_monthly_weekday,
        :start_date,
        :end_date,
        :start_time,
        :end_time
      ],
      empty_values: ["", nil]
    )
    |> cast_assoc(:departments, required: false)
    |> cast_assoc(:emails, required: true)
    |> cast_assoc(:equipment, required: false)
    |> cast_assoc(:groups, required: false)
    |> cast_assoc(:notes, required: true)
    |> cast_assoc(:phones, required: true)
    |> validate_required([
      :club_id,
      :name,
      :status,
      :venue_type,
      :period_type,
      :start_date,
      :end_date,
      :start_time,
      :end_time
    ])
    |> update_change(:name, &String.trim/1)
    |> update_change(:reference_number, &String.trim/1)
    |> update_change(:description, &String.trim/1)
    |> validate_length(:name, max: 250)
    |> validate_length(:reference_number, max: 250)
    |> validate_length(:description, max: 20_000)
    |> validate_inclusion(
      :status,
      get_valid_statuses() |> Enum.map(fn status -> status[:value] end)
    )
    |> validate_number(:minimum_participants,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 100_000
    )
    |> validate_number(:maximum_participants,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 100_000
    )
    |> validate_number(:minimum_age_in_years,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 125
    )
    |> validate_number(:maximum_age_in_years,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 125
    )
    |> validate_numbers_order(
      :minimum_participants,
      :maximum_participants,
      "Muss größer oder gleich \"Minimale Anzahl an Teilnehmern\" sein!"
    )
    |> validate_numbers_order(
      :minimum_age_in_years,
      :maximum_age_in_years,
      "Muss größer oder gleich \"Mindestalter\" sein!"
    )
    |> validate_inclusion(
      :venue_type,
      get_valid_venue_types() |> Enum.map(fn venue_type -> venue_type[:value] end)
    )

    |> validate_required_venue_type_condition()
    |> validate_length(:venue_description, max: 20_000)
    |> validate_inclusion(
      :period_type,
      get_valid_period_types() |> Enum.map(fn period_type -> period_type[:value] end)
    )

    |> validate_recurrence_fields()
    |> create_recurrence_rule()

  end

  defp validate_required_venue_type_condition(%Ecto.Changeset{} = changeset) do
    # Some fields are only required if the venue_type has a certain value.
    require Logger
    case get_field(changeset, :venue_type) do
      "location" ->
        Logger.debug("params event_locations: #{inspect(changeset.params["event_locations"])}")
        changeset |> cast_assoc(:event_locations, required: true, with: &Sportyweb.Calendar.EventLocation.changeset/2)

      "postal_address" ->
        changeset |> cast_assoc(:postal_addresses, required: true)

      "free_form" ->
        changeset |> validate_required([:venue_description])

      _ ->
        Logger.debug("Keine Änderung")
        changeset
    end
  end

  defp validate_recurrence_fields(changeset) do
    # Validate recurrence fields based on the period_type and occurrence_type.
    # If period_type is "recurring" and occurrence_type is "weekly", then recurrence_weekdays must be present.
    # If period_type is "recurring" and occurrence_type is "monthly", then recurrence_monthly_type must be present.
    # If recurrence_monthly_type is "day_of_month", then recurrence_monthly_day must be present.
    # If recurrence_monthly_type is "weekday_of_month", then recurrence_monthly_nth and recurrence_monthly_weekday must be present.
    period_type = get_field(changeset, :period_type)
    occurrence_type = get_field(changeset, :occurrence_type)

    cond do
      period_type == "recurring" and occurrence_type == "weekly" ->
        changeset
        |> validate_required([:recurrence_weekdays], message: "Bitte mindestens einen Wochentag auswählen.")

      period_type == "recurring" and occurrence_type == "monthly" ->
        monthly_type = get_field(changeset, :recurrence_monthly_type)

        changeset
        |> validate_required([:recurrence_monthly_type], message: "Bitte eine monatliche Wiederholungsart wählen.")
        |> case do
          cs when monthly_type == "day_of_month" ->
            validate_required(cs, [:recurrence_monthly_day], message: "Bitte einen Tag im Monat angeben.")
          cs when monthly_type == "weekday_of_month" ->
            cs
            |> validate_required([:recurrence_monthly_nth], message: "Bitte die Position im Monat wählen.")
            |> validate_required([:recurrence_monthly_weekday], message: "Bitte einen Wochentag wählen.")
          cs -> cs
        end

      true ->
        changeset
    end
  end

  defp build_start_datetime(cs) do
    case {get_field(cs, :start_date), get_field(cs, :start_time)} do
      {%Date{} = d, %Time{} = t} -> {:ok, NaiveDateTime.new!(d, t)}
      _ -> :error
    end
  end



  defp weekday_str_to_atom(s) when is_binary(s) do
    # Convert a string like "mon", "tue", etc. to the corresponding atom :monday, :tuesday, etc.
    # Change alle Strings to lowercase to ensure case-insensitivity
    case String.downcase(String.trim(s)) do
      "mon" -> :monday
      "tue" -> :tuesday
      "wed" -> :wednesday
      "thu" -> :thursday
      "fri" -> :friday
      "sat" -> :saturday
      "sun" -> :sunday
      _ -> nil
    end
  end

  defp weekday_atom_to_rrule_str(:monday), do: "MO"
  defp weekday_atom_to_rrule_str(:tuesday), do: "TU"
  defp weekday_atom_to_rrule_str(:wednesday), do: "WE"
  defp weekday_atom_to_rrule_str(:thursday), do: "TH"
  defp weekday_atom_to_rrule_str(:friday), do: "FR"
  defp weekday_atom_to_rrule_str(:saturday), do: "SA"
  defp weekday_atom_to_rrule_str(:sunday), do: "SU"
  defp weekday_atom_to_rrule_str(_), do: nil

  defp create_recurrence_rule(changeset) do
    require Logger
    # Create the recurrence_rule field based on the other recurrence fields.

    if get_field(changeset, :period_type) == "recurring" do
      occurrence_type = get_field(changeset, :occurrence_type)
      with {:ok, start_datetime} <- build_start_datetime(changeset) do
        Logger.debug("Start der rrule Erstellung")
        until_opt =
          case get_field(changeset, :end_date) do
            %Date{} = d ->
              ndt = NaiveDateTime.new!(d, get_field(changeset, :end_time) || ~T[00:00:00])
              [until: ndt]
            _ -> []
          end

        schedule =
          case occurrence_type do
            "daily" ->
              Logger.debug("daily")
              Cocktail.Schedule.new(start_datetime)
              |> Cocktail.Schedule.add_recurrence_rule(:daily, until_opt)

            "weekly" ->
              Logger.debug("weekly")
              days =
                changeset
                |> get_field(:recurrence_weekdays)
                |> List.wrap()
                |> Enum.map(&weekday_str_to_atom/1)
                |> Enum.reject(&is_nil/1)
              Logger.debug("#{inspect(days)}")
              if days == [] do
                Logger.debug("Keine Tage vorhanden #{inspect(get_field(changeset, :recurrence_weekdays))}")
                nil
              else
                Cocktail.Schedule.new(start_datetime)
                |> Cocktail.Schedule.add_recurrence_rule(:weekly, Keyword.merge([days: days], until_opt))
              end

            "monthly" ->
              #Logger.debug("monthly")
              monthly_type = get_field(changeset, :recurrence_monthly_type)
              case monthly_type do
                "day_of_month" ->
                  day = get_field(changeset, :recurrence_monthly_day)
                  Logger.debug("monthly day_of_month #{inspect(day)}")
                  if is_integer(day) do
                    Cocktail.Schedule.new(start_datetime)
                    |> Cocktail.Schedule.add_recurrence_rule(:monthly, Keyword.merge([days_of_month: [day]], until_opt))
                  else
                    Logger.debug("Keine Tage vorhanden #{inspect(get_field(changeset, :recurrence_monthly_day))}")
                    nil
                  end
                "weekday_of_month" ->
                  nth = get_field(changeset, :recurrence_monthly_nth)
                  weekday = get_field(changeset, :recurrence_monthly_weekday)
                  weekday_atom = weekday_str_to_atom(weekday)
                  Logger.debug("monthly weekday_of_month #{inspect({nth, weekday, weekday_atom})}")
                  ical_day = weekday_atom_to_rrule_str(weekday_atom)

                  until_clause =
                    case Keyword.get(until_opt, :until) do
                      %NaiveDateTime{} = ndt -> ";UNTIL=" <> Calendar.strftime(ndt, "%Y%m%dT%H%M%S")
                      %DateTime{} = dt      -> ";UNTIL=" <> Calendar.strftime(dt, "%Y%m%dT%H%M%SZ")
                      _ -> ""
                    end

                  if is_integer(nth) and ical_day do
                    "RRULE:FREQ=MONTHLY;BYDAY=#{Integer.to_string(nth)}#{ical_day}#{until_clause}"
                  else
                    Logger.debug("Keine Tage vorhanden #{inspect(get_field(changeset, :recurrence_monthly_weekday))}")
                    nil
                  end
                _ -> nil
              end

            "yearly" ->
              Logger.debug("yearly")
              dmonth  = start_datetime.month
              dday  = start_datetime.day

              until_clause =
                case Keyword.get(until_opt, :until) do
                  %NaiveDateTime{} = ndt -> ";UNTIL=" <> Calendar.strftime(ndt, "%Y%m%dT%H%M%S")
                  %DateTime{}     = dt  -> ";UNTIL=" <> Calendar.strftime(dt, "%Y%m%dT%H%M%SZ")
                  _ -> ""
                end

              "RRULE:FREQ=YEARLY;BYMONTH=#{dmonth};BYMONTHDAY=#{dday}#{until_clause}"

            _ -> nil
          end

        cond do
          is_binary(schedule)  ->
            # kurzfrsitig keine bessere Lösung gefunden
            Logger.debug(schedule)
            put_change(changeset, :recurrence_rule, schedule)
          is_struct(schedule, Cocktail.Schedule) ->
            rrule = Cocktail.Schedule.to_i_calendar_rrule(schedule)
            Logger.debug(rrule)
            put_change(changeset, :recurrence_rule, rrule)
          true ->
            changeset
        end
      else
        {:error, _reason} = err ->
          Logger.debug("build_start_datetime failed: #{inspect(err)}")
          changeset
        _ ->
          changeset
      end
    else
      changeset
    end
  end
end
