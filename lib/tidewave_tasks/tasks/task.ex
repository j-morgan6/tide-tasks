defmodule TidewaveTasks.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :title, :string
    field :description, :string
    field :status, :string, default: "todo"
    field :important, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :status, :important])
    |> validate_required([:title])
    |> validate_inclusion(:status, ["todo", "in_progress", "finished"])
    |> validate_length(:title, min: 1, max: 255)
    |> validate_length(:description, max: 1000)
  end
end
