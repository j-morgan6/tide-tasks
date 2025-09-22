defmodule TidewaveTasksWeb.TaskController do
  use TidewaveTasksWeb, :controller

  alias TidewaveTasks.Tasks
  alias TidewaveTasks.Tasks.Task

  def index(conn, _params) do
    tasks = Tasks.list_tasks_grouped_by_status()
    changeset = Tasks.change_task(%Task{})
    render(conn, :index, tasks: tasks, changeset: changeset)
  end

  def create(conn, %{"task" => task_params}) do
    case Tasks.create_task(task_params) do
      {:ok, _task} ->
        conn
        |> put_flash(:info, "Task created successfully.")
        |> redirect(to: ~p"/tasks")

      {:error, %Ecto.Changeset{} = changeset} ->
        tasks = Tasks.list_tasks_grouped_by_status()
        render(conn, :index, tasks: tasks, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    task = Tasks.get_task!(id)
    render(conn, :show, task: task)
  end

  def edit(conn, %{"id" => id}) do
    task = Tasks.get_task!(id)
    changeset = Tasks.change_task(task)
    render(conn, :edit, task: task, changeset: changeset)
  end

  def update(conn, %{"id" => id, "task" => task_params}) do
    task = Tasks.get_task!(id)

    case Tasks.update_task(task, task_params) do
      {:ok, _task} ->
        conn
        |> put_flash(:info, "Task updated successfully.")
        |> redirect(to: ~p"/tasks")

      {:error, %Ecto.Changeset{} = _changeset} ->
        conn
        |> put_flash(:error, "Unable to update task.")
        |> redirect(to: ~p"/tasks")
    end
  end

  def update_status(conn, %{"id" => id} = params) do
    task = Tasks.get_task!(id)
    status = params["status"] || Map.get(conn.query_params, "status")

    case Tasks.change_task_status(task, status) do
      {:ok, _task} ->
        conn
        |> put_flash(:info, "Task moved successfully.")
        |> redirect(to: ~p"/tasks")

      {:error, %Ecto.Changeset{} = _changeset} ->
        conn
        |> put_flash(:error, "Unable to move task.")
        |> redirect(to: ~p"/tasks")
    end
  end

  def delete(conn, %{"id" => id}) do
    task = Tasks.get_task!(id)
    {:ok, _task} = Tasks.delete_task(task)

    conn
    |> put_flash(:info, "Task deleted successfully.")
    |> redirect(to: ~p"/tasks")
  end
end
