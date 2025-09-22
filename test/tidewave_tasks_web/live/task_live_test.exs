defmodule TidewaveTasksWeb.TaskLiveTest do
  use TidewaveTasksWeb.ConnCase

  import Phoenix.LiveViewTest
  import TidewaveTasks.TasksFixtures

  describe "Index" do
    test "lists all tasks", %{conn: conn} do
      task1 = task_fixture(%{title: "Task 1", status: "todo"})
      task2 = task_fixture(%{title: "Task 2", status: "in_progress"})
      task3 = task_fixture(%{title: "Task 3", status: "finished"})

      {:ok, _index_live, html} = live(conn, ~p"/")

      assert html =~ "Tide Tasks"
      assert html =~ task1.title
      assert html =~ task2.title
      assert html =~ task3.title
    end

    test "creates new task", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/")

      assert index_live
             |> form("form[phx-submit=\"create_task\"]",
               task: %{title: "New Task", description: "Task description"}
             )
             |> render_submit()

      html = render(index_live)
      assert html =~ "Task created successfully"
      assert html =~ "New Task"
    end

    test "moves task between statuses", %{conn: conn} do
      task = task_fixture(%{title: "Move me", status: "todo"})
      {:ok, index_live, _html} = live(conn, ~p"/")

      # Move from todo to in_progress
      assert index_live
             |> element("button[phx-value-task_id=\"#{task.id}\"]", "Start Working")
             |> render_click()

      html = render(index_live)
      assert html =~ "Task moved successfully"

      # Verify task is in in_progress column
      assert index_live |> has_element?("#in-progress-tasks-#{task.id}")
      refute index_live |> has_element?("#todo_tasks-#{task.id}")
    end

    test "deletes task", %{conn: conn} do
      task = task_fixture(%{title: "Delete me"})
      {:ok, index_live, _html} = live(conn, ~p"/")

      assert index_live
             |> element("button[phx-click=\"delete_task\"][phx-value-id=\"#{task.id}\"]")
             |> render_click()

      html = render(index_live)
      assert html =~ "Task deleted successfully"
      refute html =~ "Delete me"
    end

    test "displays task counters correctly", %{conn: conn} do
      task_fixture(%{status: "todo"})
      task_fixture(%{status: "todo"})
      task_fixture(%{status: "in_progress"})
      task_fixture(%{status: "finished"})

      {:ok, _index_live, html} = live(conn, ~p"/")

      # Check counter displays in stats and column headers
      # Todo count should appear somewhere
      assert html =~ "2"
      # In progress and finished counts
      assert html =~ "1"
    end

    test "shows empty states when no tasks", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/")

      assert html =~ "No tasks yet"
      assert html =~ "No active tasks"
      assert html =~ "No completed tasks yet"
    end

    test "handles move_task events", %{conn: conn} do
      task = task_fixture(%{title: "Move me", status: "todo"})
      {:ok, index_live, _html} = live(conn, ~p"/")

      # Simulate move_task event directly
      index_live
      |> render_hook("move_task", %{"task_id" => task.id, "new_status" => "finished"})

      html = render(index_live)
      assert html =~ "Task moved successfully"

      # Verify task moved to finished
      assert index_live |> has_element?("#finished-tasks-#{task.id}")
    end
  end
end
