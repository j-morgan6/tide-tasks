defmodule TidewaveTasksWeb.PageController do
  use TidewaveTasksWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
