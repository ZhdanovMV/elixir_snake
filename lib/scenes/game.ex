defmodule ElixirSnake.Scene.Game do
  use Scenic.Scene

  alias ElixirSnake.GameGraph
  alias Scenic.Graph
  alias Scenic.ViewPort

  @game_settings Application.get_env(:elixir_snake, :game_settings)

  def init(_arg, opts) do
    viewport = opts[:viewport]

    # Calculate the transform that centers the snake in the viewport.
    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)

    # How many tiles can the viewport hold in each dimension?
    vp_tile_width = trunc(vp_width / @game_settings.tile_size)
    vp_tile_height = trunc(vp_height / @game_settings.tile_size)

    # Snake always starts centered.
    snake_start_coords = {trunc(vp_tile_width / 2), trunc(vp_tile_height / 2)}

    # Pellet starts at snake's right.
    pellet_start_coords = {vp_tile_width - 2, trunc(vp_tile_height / 2)}

    # Start a very simple animation timer.
    {:ok, timer} = :timer.send_interval(@game_settings.frame_ms, :frame)

    # The entire game state will be held here.
    state = %{
      viewport: viewport,
      tile_width: vp_tile_width,
      tile_height: vp_tile_height,
      graph: Graph.build(font: :roboto, font_size: 36),
      frame_count: 1,
      frame_timer: timer,
      score: 0,
      objects: %{
        snake: %{
          body: [snake_start_coords],
          size: @game_settings.snake_starting_size,
          direction: {1, 0}
        },
        pellet: pellet_start_coords
      }
    }

    graph = state.graph
            |> GameGraph.draw_score(state.score)
            |> GameGraph.draw_game_objects(state.objects)

    {:ok, state, push: graph}
  end

  def handle_info(:frame, %{frame_count: frame_count} = state) do
    state = move_snake(state)

    graph = state.graph
            |> GameGraph.draw_game_objects(state.objects)
            |> GameGraph.draw_score(state.score)

    {:noreply, %{state | frame_count: frame_count + 1}, push: graph}
  end

  # Keyboard controls.
  def handle_input({:key, {"left", :press, _}}, _context, state) do
    {:noreply, update_snake_direction(state, {-1, 0})}
  end

  def handle_input({:key, {"right", :press, _}}, _context, state) do
    {:noreply, update_snake_direction(state, {1, 0})}
  end

  def handle_input({:key, {"up", :press, _}}, _context, state) do
    {:noreply, update_snake_direction(state, {0, -1})}
  end

  def handle_input({:key, {"down", :press, _}}, _context, state) do
    {:noreply, update_snake_direction(state, {0, 1})}
  end

  def handle_input(_input, _context, state), do: {:noreply, state}

  # Move the snake to its next position according to the direction. Also limits the size.
  defp move_snake(%{objects: %{snake: snake}} = state) do
    [head | _] = snake.body
    new_head_pos = move(state, head, snake.direction)

    new_body = Enum.take([new_head_pos | snake.body], snake.size)

    state
    |> put_in([:objects, :snake, :body], new_body)
    |> maybe_eat_pellet(new_head_pos)
    |> maybe_die()
  end

  defp move(%{tile_width: w, tile_height: h}, {pos_x, pos_y}, {vec_x, vec_y}) do
    {rem(pos_x + vec_x + w, w), rem(pos_y + vec_y + h, h)}
  end

  # Change the snake's current direction.
  defp update_snake_direction(state, direction) do
    put_in(state, [:objects, :snake, :direction], direction)
  end

  # Eat pellet if snake's head is on top of it.
  defp maybe_eat_pellet(state = %{objects: %{pellet: pellet_coords}}, snake_head_coords)
       when pellet_coords == snake_head_coords do
    state
    |> randomize_pellet()
    |> add_score(@game_settings.pellet_score)
    |> grow_snake()
  end

  defp maybe_eat_pellet(state, _), do: state

  # Place the pellet somewhere in the map. It should not be on top of the snake.
  defp randomize_pellet(state = %{tile_width: w, tile_height: h}) do
    pellet_coords = {
      Enum.random(0..(w-1)),
      Enum.random(0..(h-1)),
    }

    validate_pellet_coords(state, pellet_coords)
  end

  # Keep trying until we get a valid position.
  defp validate_pellet_coords(state = %{objects: %{snake: %{body: snake}}}, coords) do
    if coords in snake, do: randomize_pellet(state),
                        else: put_in(state, [:objects, :pellet], coords)
  end

  # Increments the player's score.
  defp add_score(state, amount) do
    update_in(state, [:score], &(&1 + amount))
  end

  # Increments the snake size.
  defp grow_snake(state) do
    update_in(state, [:objects, :snake, :size], &(&1 + 1))
  end

  defp maybe_die(state = %{viewport: vp, objects: %{snake: %{body: snake}}, score: score}) do
    # If ANY duplicates were removed, this means we overlapped at least once
    if length(Enum.uniq(snake)) < length(snake) do
      ViewPort.set_root(vp, {ElixirSnake.Scene.GameOver, score})
    end
    state
  end
end
