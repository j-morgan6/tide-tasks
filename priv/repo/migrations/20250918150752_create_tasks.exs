defmodule TidewaveTasks.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :title, :string, null: false
      add :description, :text
      add :status, :string, default: "todo", null: false

      timestamps(type: :utc_datetime)
    end

    create index(:tasks, [:status])
  end
end
