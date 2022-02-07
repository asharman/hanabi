defmodule HanabiWeb.LobbyController do
  use HanabiWeb, :controller
  import Ecto.Changeset
  @form_types %{username: :string}

  def show(conn, %{"name" => name}) do
    changeset = change({%{}, @form_types})
    render(conn, HanabiWeb.LobbyLive, session: %{changeset: changeset, name: name})
  end

  def join(conn, %{"name" => name, "player" => player_params}) do
    case cast_params(player_params, @form_types) do
      {:ok, %{username: new_player}} ->
        redirect(conn, to: Routes.game_path(conn, :join, name, player: new_player))

      {:error, %Ecto.Changeset{} = changeset} ->
        live_render(conn, HanabiWeb.LobbyLive, session: %{changeset: changeset, name: name})
    end
  end

  defp cast_params(form_data, type_map) do
    {%{}, type_map}
    |> cast(form_data, Map.keys(type_map))
    |> validate_required([:username])
    |> apply_action(:update)
  end
end
