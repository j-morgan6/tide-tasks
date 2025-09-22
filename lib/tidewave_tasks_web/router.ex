defmodule TidewaveTasksWeb.Router do
  use TidewaveTasksWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TidewaveTasksWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TidewaveTasksWeb do
    pipe_through :browser

    live "/", TaskLive.Index, :index
    live "/tasks", TaskLive.Index, :index
    live "/completed", TaskLive.Completed, :completed
    post "/tasks", TaskController, :create
    get "/tasks/:id", TaskController, :show
    get "/tasks/:id/edit", TaskController, :edit
    patch "/tasks/:id", TaskController, :update
    put "/tasks/:id", TaskController, :update
    get "/tasks/:id/status", TaskController, :update_status
    patch "/tasks/:id/status", TaskController, :update_status
    delete "/tasks/:id", TaskController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", TidewaveTasksWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:tidewave_tasks, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TidewaveTasksWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
