defmodule TidewaveTasks.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  alias TidewaveTasks.Repo

  alias TidewaveTasks.Tasks.Task

  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks()
      [%Task{}, ...]

  """
  def list_tasks do
    Repo.all(Task)
  end

  @doc """
  Returns the list of tasks filtered by status.

  ## Examples

      iex> list_tasks_by_status("todo")
      [%Task{}, ...]

  """
  def list_tasks_by_status(status) do
    Task
    |> where([t], t.status == ^status)
    |> order_by([t], desc: t.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single task.

  Raises `Ecto.NoResultsError` if the Task does not exist.

  ## Examples

      iex> get_task!(123)
      %Task{}

      iex> get_task!(456)
      ** (Ecto.NoResultsError)

  """
  def get_task!(id), do: Repo.get!(Task, id)

  @doc """
  Creates a task.

  ## Examples

      iex> create_task(%{field: value})
      {:ok, %Task{}}

      iex> create_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a task.

  ## Examples

      iex> update_task(task, %{field: new_value})
      {:ok, %Task{}}

      iex> update_task(task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a task's status.

  ## Examples

      iex> change_task_status(task, "in_progress")
      {:ok, %Task{}}

  """
  def change_task_status(%Task{} = task, new_status) do
    attrs = 
      if new_status == "finished" do
        %{status: new_status, important: false}
      else
        %{status: new_status}
      end
    
    update_task(task, attrs)
  end

  @doc """
  Deletes a task.

  ## Examples

      iex> delete_task(task)
      {:ok, %Task{}}

      iex> delete_task(task)
      {:error, %Ecto.Changeset{}}

  """
  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  @doc """
  Toggles a task's importance status.

  ## Examples

      iex> toggle_task_importance(task)
      {:ok, %Task{}}

  """
  def toggle_task_importance(%Task{} = task) do
    update_task(task, %{important: !task.important})
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task changes.

  ## Examples

      iex> change_task(task)
      %Ecto.Changeset{data: %Task{}}

  """
  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  @doc """
  Returns tasks grouped by status.

  ## Examples

      iex> list_tasks_grouped_by_status()
      %{
        "todo" => [%Task{}, ...],
        "in_progress" => [%Task{}, ...],
        "finished" => [%Task{}, ...]
      }

  """
  def list_tasks_grouped_by_status do
    tasks = list_tasks()

    %{
      "todo" => Enum.filter(tasks, &(&1.status == "todo")),
      "in_progress" => Enum.filter(tasks, &(&1.status == "in_progress")),
      "finished" => Enum.filter(tasks, &(&1.status == "finished"))
    }
  end
end
