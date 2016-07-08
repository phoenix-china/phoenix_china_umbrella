defmodule PhoenixChina.RoomChannel do
  use Phoenix.Channel

  def join("rooms:lobby", msg, socket) do
    send(self, {:after_join, msg})
    {:ok, socket}
  end

  def join("rooms:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_info({:after_join, msg}, socket) do
    broadcast! socket, "user:entered", %{user: msg["user"]}
    {:noreply, socket}
  end

  def handle_in("new_msg", msg, socket) do
    broadcast! socket, "new_msg", msg
    {:noreply, socket}
  end
end
