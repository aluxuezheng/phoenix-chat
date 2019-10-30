defmodule ChatWeb.RoomChannel do
  use Phoenix.Channel

  def join("room:lobby", _message, socket) do
    {:ok, socket}
  end

  def join("room:" <> roomId, _payload, socket) do
    send(self, :afterJoin)
    {:ok, socket}
  end

  def join("topic:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast_from(socket, "new_msg", %{body: body, messageType: 2})
    push(socket, "new_msg", %{body: body, messageType: 1})
    {:noreply, socket}
  end

  def handle_in("fetch:room", _, socket) do
    token = socket.assigns.token
    roomId = getRoomId(socket, token)
    push(socket, "rooms:connected", %{roomId: roomId })
    {:noreply, assign(socket, :roomId, roomId)}
  end

  def getRoomId(socket, token) do
    # token = socket.assigns.token
    {_, conn} = getRedisConn()
    {_, roomId} = Redix.command(conn, ["GET", token])
    roomId = case String.valid?(roomId) do
      true ->
        roomId
      _ ->
        {_, roomId} = Redix.command(conn, ["GET", "roomId"])
        roomId = case String.valid?(roomId) do
          true ->
            Redix.command(conn, ["DEL", "roomId"])
            roomId
          _ ->
            roomId = UUID.uuid1()
            Redix.command(conn, ["SET", "roomId", roomId])
            Redix.command(conn, ["SET", token, roomId])
            roomId
        end
        roomId
    end
    roomId
  end

  def getRedisConn() do
    {_, conn} = Redix.start_link("redis://127.0.0.1", port: 6379, password: "123456")
  end

  def getValueFromRedis(key) do
    {_, conn} = getRedisConn()
    {_, roomId} = Redix.command(conn, ["GET", key])
    {roomId, conn}
  end

  def handle_info(:afterJoin, socket) do
    {roomId, _} = getValueFromRedis("roomId")
    {tokenRoomId, _} = getValueFromRedis(socket.assigns.token)
    cond do
      String.valid?(tokenRoomId) && tokenRoomId != roomId-> broadcast(socket, "someone_leave", %{messageType: 0})
      !String.valid?(roomId) -> broadcast(socket, "someone_connect", %{messageType: 0})
      true -> nil
    end
    {:noreply, assign(socket, :roomId, roomId)}
  end

  def handle_in("user:typing", %{"typing" => typing}, socket) do
    broadcast_from(socket, "typing", %{typing: typing, messageType: 0})
    {:noreply, socket}
  end

  def handle_in("someone_leave", _, socket) do
    {roomId, conn} = getValueFromRedis("roomId")
    if socket.assigns.roomId == roomId do
      Redix.command(conn, ["DEL", "roomId"])
    end
    Redix.command(conn, ["DEL", socket.assigns.token])
    broadcast_from(socket, "someone_leave", %{messageType: 0})
    {:noreply, socket}
  end
end
