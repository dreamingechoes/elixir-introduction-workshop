defmodule ElixirTwitterBot.Endpoint do
  @moduledoc """
  A Plug responsible for logging request info, parsing request body's as JSON,
  matching routes, and dispatching responses.
  """

  use Plug.Router
  use Plug.ErrorHandler

  # This module is a Plug, that also implements it's own plug pipeline, below:

  # Using Plug.Logger for logging request information
  plug(Plug.Logger)

  # Responsible for matching routes
  plug(:match)

  # Using Jason for JSON encoding.
  # Note, order of plugs is important, by placing this _after_ the 'match' plug,
  # we will only parse the request AFTER there is a route match.
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)

  # Responsible for dispatching responses
  plug(:dispatch)

  # A simple route to test that the server is up.
  # Note, all routes must return a connection as per the Plug spec.
  get "/ping" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(%{:message => "Pong!"}))
  end

  # Endpoint to post a new tweet to our Twitter's account
  post "/update" do
    conn
    |> ElixirTwitterBot.update_status()
    |> generate_response(conn)
  end

  # Endpoint to search tweets by a query
  get "/search" do
    conn
    |> ElixirTwitterBot.search()
    |> generate_response(conn)
  end

  # Endpoint to retweet a tweet to our Twitter's account
  post "/retweet" do
    conn
    |> ElixirTwitterBot.retweet()
    |> generate_response(conn)
  end

  # Handle incoming requests.

  # A catchall route, 'match' will match no matter the request method,
  # so a response is always returned, even if there is no route to match.
  match _ do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(
      404,
      Jason.encode!(%{:message => "Endpoint not found"})
    )
  end

  defp handle_errors(conn, %{
         kind: _kind,
         reason: _reason,
         stack: _stack
       }) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(
      conn.status,
      Jason.encode!(%{:message => "Unexcepted error"})
    )
  end

  defp generate_response({:ok, result}, conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(result))
  end

  defp generate_response({:error, message}, conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(500, Jason.encode!(%{:message => message}))
  end
end
