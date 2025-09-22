defmodule TidewaveTasks.Tasks.TaskTest do
  use TidewaveTasks.DataCase

  alias TidewaveTasks.Tasks.Task

  describe "changeset/2" do
    test "changeset with valid attributes" do
      attrs = %{title: "Valid task", description: "Task description", status: "todo"}
      changeset = Task.changeset(%Task{}, attrs)
      assert changeset.valid?
    end

    test "changeset requires title" do
      attrs = %{description: "Task description", status: "todo"}
      changeset = Task.changeset(%Task{}, attrs)
      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).title
    end

    test "changeset validates title length" do
      attrs = %{title: String.duplicate("a", 256), status: "todo"}
      changeset = Task.changeset(%Task{}, attrs)
      refute changeset.valid?
      assert "should be at most 255 character(s)" in errors_on(changeset).title
    end

    test "changeset validates minimum title length" do
      attrs = %{title: "", status: "todo"}
      changeset = Task.changeset(%Task{}, attrs)
      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).title
    end

    test "changeset validates description length" do
      attrs = %{title: "Valid task", description: String.duplicate("a", 1001), status: "todo"}
      changeset = Task.changeset(%Task{}, attrs)
      refute changeset.valid?
      assert "should be at most 1000 character(s)" in errors_on(changeset).description
    end

    test "changeset validates status inclusion" do
      attrs = %{title: "Valid task", status: "invalid_status"}
      changeset = Task.changeset(%Task{}, attrs)
      refute changeset.valid?
      assert "is invalid" in errors_on(changeset).status
    end

    test "changeset allows valid statuses" do
      valid_statuses = ["todo", "in_progress", "finished"]

      for status <- valid_statuses do
        attrs = %{title: "Valid task", status: status}
        changeset = Task.changeset(%Task{}, attrs)
        assert changeset.valid?, "Status #{status} should be valid"
      end
    end

    test "changeset defaults status to todo" do
      attrs = %{title: "Valid task"}
      changeset = Task.changeset(%Task{}, attrs)
      assert changeset.valid?
      assert Ecto.Changeset.get_field(changeset, :status) == "todo"
    end

    test "changeset allows nil description" do
      attrs = %{title: "Valid task", description: nil, status: "todo"}
      changeset = Task.changeset(%Task{}, attrs)
      assert changeset.valid?
    end
  end
end
