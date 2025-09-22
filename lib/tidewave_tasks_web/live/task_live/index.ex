defmodule TidewaveTasksWeb.TaskLive.Index do
  use TidewaveTasksWeb, :live_view

  alias TidewaveTasks.Tasks
  alias TidewaveTasks.Tasks.Task

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream_tasks(socket)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Tide Tasks")
    |> assign(:task, nil)
  end

  @impl true
  def handle_event("create_task", %{"task" => task_params}, socket) do
    case Tasks.create_task(task_params) do
      {:ok, task} ->
        {:noreply,
         socket
         |> put_flash(:info, "Task created successfully")
         |> stream_insert(:todo_tasks, task, at: 0)
         |> update_task_counts()
         |> assign(:form, to_form(Tasks.change_task(%Task{})))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @impl true
  def handle_event("move_task", %{"task_id" => task_id, "new_status" => new_status}, socket) do
    task = Tasks.get_task!(task_id)

    case Tasks.change_task_status(task, new_status) do
      {:ok, updated_task} ->
        {:noreply,
         socket
         |> put_flash(:info, "Task moved successfully")
         |> stream_delete_by_dom_id(:todo_tasks, "todo_tasks-#{task.id}")
         |> stream_delete_by_dom_id(:in_progress_tasks, "in_progress_tasks-#{task.id}")
         |> stream_delete_by_dom_id(:finished_tasks, "finished_tasks-#{task.id}")
         |> stream_insert(status_to_stream(new_status), updated_task, at: 0)
         |> update_task_counts()}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Unable to move task")}
    end
  end

  @impl true
  def handle_event("toggle_importance", %{"id" => id}, socket) do
    task = Tasks.get_task!(id)
    
    case Tasks.toggle_task_importance(task) do
      {:ok, updated_task} ->
        {:noreply,
         socket
         |> stream_delete_by_dom_id(:todo_tasks, "todo_tasks-#{task.id}")
         |> stream_delete_by_dom_id(:in_progress_tasks, "in_progress_tasks-#{task.id}")
         |> stream_delete_by_dom_id(:finished_tasks, "finished_tasks-#{task.id}")
         |> stream_insert(status_to_stream(updated_task.status), updated_task, at: 0)}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Unable to update task importance")}
    end
  end

  @impl true
  def handle_event("delete_task", %{"id" => id}, socket) do
    task = Tasks.get_task!(id)
    {:ok, _} = Tasks.delete_task(task)

    {:noreply,
     socket
     |> put_flash(:info, "Task deleted successfully")
     |> stream_delete(:todo_tasks, task)
     |> stream_delete(:in_progress_tasks, task)
     |> stream_delete(:finished_tasks, task)
     |> update_task_counts()}
  end

  defp stream_tasks(socket) do
    tasks = Tasks.list_tasks_grouped_by_status()

    socket
    |> assign(:form, to_form(Tasks.change_task(%Task{})))
    |> assign(:todo_count, length(tasks["todo"]))
    |> assign(:in_progress_count, length(tasks["in_progress"]))
    |> assign(:finished_count, length(tasks["finished"]))
    |> stream(:todo_tasks, tasks["todo"])
    |> stream(:in_progress_tasks, tasks["in_progress"])
    |> stream(:finished_tasks, tasks["finished"])
  end

  defp update_task_counts(socket) do
    tasks = Tasks.list_tasks_grouped_by_status()

    socket
    |> assign(:todo_count, length(tasks["todo"]))
    |> assign(:in_progress_count, length(tasks["in_progress"]))
    |> assign(:finished_count, length(tasks["finished"]))
  end

  defp status_to_stream("todo"), do: :todo_tasks
  defp status_to_stream("in_progress"), do: :in_progress_tasks
  defp status_to_stream("finished"), do: :finished_tasks
end
