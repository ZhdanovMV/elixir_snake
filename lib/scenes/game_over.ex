defmodule ElixirSnake.Scene.GameOver do
  use Scenic.Scene

  import Scenic.Primitives, only: [text: 3, update_opts: 2]

  alias Scenic.Graph
  alias Scenic.ViewPort

  @text_opts [id: :gameover, fill: :white, text_align: :center]

  @graph Graph.build(font: :roboto, font_size: 36, clear_color: :black)
         |> text("Game Over!", @text_opts)

  @game_scene ElixirSnake.Scene.Game

  def init(score, opts) do
    viewport = opts[:viewport]

    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)

    position = {vp_width / 2, vp_height / 2}

    graph = Graph.modify(@graph, :gameover, &update_opts(&1, translate: position))

    state = %{
      graph: graph,
      viewport: opts[:viewport],
      on_cooldown: true,
      score: score
    }

    Process.send_after(self(), :end_cooldown, 2000)

    {:ok, state, push: graph}
  end

  # Prevent player from hitting any key instantly, starting a new game.
  def handle_info(:end_cooldown, state) do
    message = "Game Over!\nYou scored #{state.score}.\nPress any key to try again."
    graph = state.graph
            |> Graph.modify(:gameover, &text(&1, message, @text_opts))

    {:noreply, %{state | on_cooldown: false, graph: graph}, push: graph}
  end

  # If cooldown has passed, we can restart the game.
  def handle_input({:key, _}, _context, %{on_cooldown: false} = state) do
    restart_game(state)
    {:noreply, state}
  end

  def handle_input(_input, _context, state), do: {:noreply, state}

  defp restart_game(%{viewport: vp}) do
    ViewPort.set_root(vp, {@game_scene, nil})
  end
end
