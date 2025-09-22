defmodule TidewaveTasks.Repo.Migrations.AddImportantToTasks do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add :important, :boolean, default: false, null: false
    end

    create index(:tasks, [:important])
  end
end
