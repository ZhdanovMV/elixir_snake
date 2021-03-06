defmodule ElixirSnake do
  @moduledoc """
  Starter application using the Scenic framework.
  """

  def start(_type, _args) do
    # Load the viewport configuration from config.
    main_viewport_config = Application.get_env(:elixir_snake, :viewport)

    # Start the application with the viewport.
    children = [
      {Scenic, viewports: [main_viewport_config]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
