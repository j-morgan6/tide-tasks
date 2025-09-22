defmodule TidewaveTasksWeb.TaskLive.Completed do
  use TidewaveTasksWeb, :live_view

  alias TidewaveTasks.Tasks
  alias TidewaveTasks.Tasks.Task

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream_completed_tasks(socket)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :completed, _params) do
    socket
    |> assign(:page_title, "Completed Tasks - Tide Tasks")
    |> assign(:task, nil)
  end

  @impl true
  def handle_event("move_task", %{"task_id" => task_id, "new_status" => new_status}, socket) do
    task = Tasks.get_task!(task_id)
    
    case Tasks.change_task_status(task, new_status) do
      {:ok, _updated_task} ->
        {:noreply,
         socket
         |> put_flash(:info, "Task moved back to active tasks")
         |> stream_delete(:completed_tasks, task)
         |> update_completed_count()}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Unable to move task")}
    end
  end

  @impl true
  def handle_event("delete_task", %{"id" => id}, socket) do
    task = Tasks.get_task!(id)
    {:ok, _} = Tasks.delete_task(task)

    {:noreply,
     socket
     |> put_flash(:info, "Task deleted successfully")
     |> stream_delete(:completed_tasks, task)
     |> update_completed_count()}
  end

  defp stream_completed_tasks(socket) do
    completed_tasks = Tasks.list_tasks_by_status("finished")

    socket
    |> assign(:completed_count, length(completed_tasks))
    |> stream(:completed_tasks, completed_tasks)
  end

  defp update_completed_count(socket) do
    completed_tasks = Tasks.list_tasks_by_status("finished")
    assign(socket, :completed_count, length(completed_tasks))
  end
end