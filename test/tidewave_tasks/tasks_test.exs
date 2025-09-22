defmodule TidewaveTasks.TasksTest do
  use TidewaveTasks.DataCase

  alias TidewaveTasks.Tasks

  describe "tasks" do
    alias TidewaveTasks.Tasks.Task

    import TidewaveTasks.TasksFixtures

    @invalid_attrs %{description: nil, status: nil, title: nil}

    test "list_tasks/0 returns all tasks" do
      task = task_fixture()
      assert Tasks.list_tasks() == [task]
    end

    test "list_tasks_by_status/1 returns tasks filtered by status" do
      todo_task = task_fixture(%{status: "todo"})
      progress_task = task_fixture(%{status: "in_progress"})
      _finished_task = task_fixture(%{status: "finished"})

      assert Tasks.list_tasks_by_status("todo") == [todo_task]
      assert Tasks.list_tasks_by_status("in_progress") == [progress_task]
      assert length(Tasks.list_tasks_by_status("finished")) == 1
    end

    test "list_tasks_grouped_by_status/0 returns tasks grouped by status" do
      todo_task = task_fixture(%{status: "todo"})
      progress_task = task_fixture(%{status: "in_progress"})
      finished_task = task_fixture(%{status: "finished"})

      grouped = Tasks.list_tasks_grouped_by_status()

      assert grouped["todo"] == [todo_task]
      assert grouped["in_progress"] == [progress_task]
      assert grouped["finished"] == [finished_task]
    end

    test "get_task!/1 returns the task with given id" do
      task = task_fixture()
      assert Tasks.get_task!(task.id) == task
    end

    test "create_task/1 with valid data creates a task" do
      valid_attrs = %{description: "some description", status: "todo", title: "some title"}

      assert {:ok, %Task{} = task} = Tasks.create_task(valid_attrs)
      assert task.description == "some description"
      assert task.status == "todo"
      assert task.title == "some title"
    end

    test "create_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tasks.create_task(@invalid_attrs)
    end

    test "create_task/1 defaults to todo status" do
      valid_attrs = %{title: "some title"}
      assert {:ok, %Task{} = task} = Tasks.create_task(valid_attrs)
      assert task.status == "todo"
    end

    test "update_task/2 with valid data updates the task" do
      task = task_fixture()

      update_attrs = %{
        description: "some updated description",
        status: "in_progress",
        title: "some updated title"
      }

      assert {:ok, %Task{} = task} = Tasks.update_task(task, update_attrs)
      assert task.description == "some updated description"
      assert task.status == "in_progress"
      assert task.title == "some updated title"
    end

    test "update_task/2 with invalid data returns error changeset" do
      task = task_fixture()
      assert {:error, %Ecto.Changeset{}} = Tasks.update_task(task, @invalid_attrs)
      assert task == Tasks.get_task!(task.id)
    end

    test "change_task_status/2 updates task status" do
      task = task_fixture(%{status: "todo"})

      assert {:ok, %Task{} = updated_task} = Tasks.change_task_status(task, "in_progress")
      assert updated_task.status == "in_progress"

      assert {:ok, %Task{} = completed_task} = Tasks.change_task_status(updated_task, "finished")
      assert completed_task.status == "finished"
    end

    test "change_task_status/2 with invalid status returns error changeset" do
      task = task_fixture()
      assert {:error, %Ecto.Changeset{}} = Tasks.change_task_status(task, "invalid_status")
    end

    test "delete_task/1 deletes the task" do
      task = task_fixture()
      assert {:ok, %Task{}} = Tasks.delete_task(task)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_task!(task.id) end
    end

    test "change_task/1 returns a task changeset" do
      task = task_fixture()
      assert %Ecto.Changeset{} = Tasks.change_task(task)
    end
  end
end
