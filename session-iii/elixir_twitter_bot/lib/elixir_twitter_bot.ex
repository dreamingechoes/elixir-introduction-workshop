defmodule ElixirTwitterBot do
  @moduledoc """
  Main module of the ElixirTwitterBot. Here we have some simple functions to
  interact with Twitter's public API through ExTwitter library.
  """
  alias ExTwitter.API.Search
  alias ExTwitter.API.Tweets

  def update_status(%Plug.Conn{body_params: %{"status" => status}}) do
    case Tweets.update(status) do
      %ExTwitter.Model.Tweet{id: id} ->
        {:ok, %{id: id, message: "New status posted succesfully!"}}

      _ ->
        {:error,
         "Something wrong happened. The status couldn't be posted right now."}
    end
  end

  def retweet(%Plug.Conn{body_params: %{"tweet_id" => tweet_id}}) do
    case Tweets.retweet(tweet_id) do
      %ExTwitter.Model.Tweet{id: id} ->
        {:ok, %{id: id, message: "Tweet retweeted succesfully!"}}

      _ ->
        {:error,
         "Something wrong happened. The tweet couldn't be retweeted right now."}
    end
  end

  def search(%Plug.Conn{query_params: %{"query" => query}}) do
    case Search.search(query) do
      tweets when is_list(tweets) ->
        results =
          Enum.map(tweets, fn %{id: id, text: text} ->
            %{id: id, text: text}
          end)

        {:ok, %{results: results}}

      _ ->
        {:error,
         "Something wrong happened. The search couldn't be done right now."}
    end
  end
end
