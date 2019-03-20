defmodule ElixirTwitterBot.EndpointTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts ElixirTwitterBot.Endpoint.init([])

  test "it returns pong" do
    # Create a test connection
    conn = conn(:get, "/ping")

    # Invoke the plug
    conn = ElixirTwitterBot.Endpoint.call(conn, @opts)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "{\"message\":\"Pong!\"}"
  end

  test "it returns 404 when no route matches" do
    # Create a test connection
    conn = conn(:get, "/fail")

    # Invoke the plug
    conn = ElixirTwitterBot.Endpoint.call(conn, @opts)

    # Assert the response
    assert conn.status == 404
  end
end
