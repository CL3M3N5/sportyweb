defmodule Sportyweb.Calendar.Event do
  use Ecto.Schema
  import Ecto.Changeset
  import SportywebWeb.CommonValidations

  alias Sportyweb.Asset.Equipment
  alias Sportyweb.Asset.Location
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
    many_to_many :contacts, Contact, join_through: EventContact
    many_to_many :departments, Department, join_through: EventDepartment
    many_to_many :emails, Email, join_through: EventEmail
    many_to_many :equipment, Equipment, join_through: EventEquipment
    many_to_many :fees, Fee, join_through: EventFee
    many_to_many :groups, Group, join_through: EventGroup
    many_to_many :notes, Note, join_through: EventNote
    many_to_many :phones, Phone, join_through: EventPhone
    many_to_many :postal_addresses, PostalAddress, join_through: EventPostalAddress
    many_to_many :locations, Location, join_through: EventLocation


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
    field :recurrence_rule, :map, default: nil
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

    |> put_recurrence_rule()

  end

  defp validate_required_venue_type_condition(%Ecto.Changeset{} = changeset) do
    # Some fields are only required if the venue_type has a certain value.
    case get_field(changeset, :venue_type) do
      "location" ->
        changeset |> cast_assoc(:locations, required: true)

      "postal_address" ->
        changeset |> cast_assoc(:postal_addresses, required: true)

      "free_form" ->
        changeset |> validate_required([:venue_description])

      _ ->
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


  defp put_recurrence_rule(changeset) do
    # If the period_type is "recurring", we need to create a recurrence rule.
    # The rule is based on the start_date and the recurrence type (weekly or monthly).
    # If the recurrence type is not set, we do not create a rule.
    if get_field(changeset, :period_type) == "recurring" do
      start_date = get_field(changeset, :start_date)
      occurrence_type = get_field(changeset, :occurrence_type)
      # Ensure start_date is a Date struct
      cond do
        occurrence_type == "weekly" and
          is_struct(start_date, Date) and
          is_list(get_field(changeset, :recurrence_weekdays)) and
          length(get_field(changeset, :recurrence_weekdays)) > 0 ->

          rule = Cocktail.Rule.new(
            start_date: start_date,
            frequency: :weekly,
            days: Enum.map(get_field(changeset, :recurrence_weekdays), &String.downcase/1)
          )
          put_change(changeset, :recurrence_rule, Cocktail.Rule.serialize(rule))

        occurrence_type == "monthly" and
          is_struct(start_date, Date) and
          get_field(changeset, :recurrence_monthly_type) == "day_of_month" and
          not is_nil(get_field(changeset, :recurrence_monthly_day)) ->

          rule = Cocktail.Rule.new(
            start_date: start_date,
            frequency: :monthly
          )
          rule = Cocktail.Rule.day_of_month(rule, [get_field(changeset, :recurrence_monthly_day)])
          put_change(changeset, :recurrence_rule, Cocktail.Rule.serialize(rule))

        occurrence_type == "monthly" and
          is_struct(start_date, Date) and
          get_field(changeset, :recurrence_monthly_type) == "weekday_of_month" and
          not is_nil(get_field(changeset, :recurrence_monthly_nth)) and
          not is_nil(get_field(changeset, :recurrence_monthly_weekday)) ->

          rule = Cocktail.Rule.new(
            start_date: start_date,
            frequency: :monthly
          )
          rule = Cocktail.Rule.day_of_week(rule, [
            {String.downcase(get_field(changeset, :recurrence_monthly_weekday)), [get_field(changeset, :recurrence_monthly_nth)]}
          ])
          put_change(changeset, :recurrence_rule, Cocktail.Rule.serialize(rule))

        true ->
          changeset
      end
    else
      changeset
    end
  end
end
