defmodule ElixirSnake.GameGraph do
  import Scenic.Primitives, only: [rrect: 3, text: 3]

  @game_settings Application.get_env(:elixir_snake, :game_settings)

  @tile_radius @game_settings.tile_radius
  @tile_size @game_settings.tile_size

  # Draw the score HUD.
  def draw_score(graph, score) do
    graph
    |> text("Score: #{score}", fill: :white, translate: {@tile_size, @tile_size})
  end

  # Iterates over the object map, rendering each object.
  def draw_game_objects(graph, object_map) do
    Enum.reduce(object_map, graph, fn({object_type, object_data}, graph) ->
      draw_object(graph, object_type, object_data)
    end)
  end

  # Snake's body is an array of coordinate pairs.
  def draw_object(graph, :snake, %{body: snake}) do
    Enum.reduce(snake, graph, fn({x, y}, graph) ->
      draw_tile(graph, x, y, fill: :lime)
    end)
  end

  # Pellet is simply a coordinate pair.
  def draw_object(graph, :pellet, {pellet_x, pellet_y}) do
    draw_tile(graph, pellet_x, pellet_y, fill: :yellow, id: :pellet)
  end

  # Draw tiles as rounded rectangles to look nice.
  defp draw_tile(graph, x, y, opts) do
    tile_opts = Keyword.merge([fill: :white, translate: {x * @tile_size, y * @tile_size}], opts)
    rrect(graph, {@tile_size, @tile_size, @tile_radius}, tile_opts)
  end
end
