# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# Configure the main viewport for the Scenic application
config :elixir_snake, :viewport, %{
  name: :main_viewport,
  size: {1280, 720},
  default_scene: {ElixirSnake.Scene.Game, nil},
  drivers: [
    %{
      module: Scenic.Driver.Glfw,
      name: :glfw,
      opts: [resizeable: false, title: "elixir_snake"]
    }
  ]
}

config :elixir_snake, :game_settings, %{
  frame_ms: 192,
  pellet_score: 1,
  snake_starting_size: 3,
  tile_radius: 8,
  tile_size: 32
}

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "prod.exs"
