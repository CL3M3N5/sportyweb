defmodule Sportyweb.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :reference_number, :string, null: false
      add :status, :string, null: false
      add :description, :text, null: false
      add :minimum_participants, :integer, null: true
      add :maximum_participants, :integer, null: true
      add :minimum_age_in_years, :integer, null: true
      add :maximum_age_in_years, :integer, null: true
      add :venue_type, :string, null: false
      add :venue_description, :text, null: false
      add :start_date, :date, null: true
      add :end_date, :date, null: true
      add :start_time, :time, null: true
      add :end_time, :time, null: true
      add :period_type, :string, null: false, default: "single"
      add :occurrence_type, :string, null: true
      add :recurrence_rule, :string, null: true
      add :recurrence_exceptions, {:array, :utc_datetime}, default: []
      add :recurrence_weekdays, {:array, :string}, default: []
      add :recurrence_monthly_type, :string, null: true
      add :recurrence_monthly_day, :integer, null: true
      add :recurrence_monthly_nth, :integer, null: true
      add :recurrence_monthly_weekday, :string, null: true
      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false
      add :department_id, references(:departments, on_delete: :nilify_all, type: :binary_id), null: true
      add :group_id, references(:groups, on_delete: :nilify_all, type: :binary_id), null: true

      timestamps(type: :utc_datetime)
    end

    create index(:events, [:club_id])
  end
end
