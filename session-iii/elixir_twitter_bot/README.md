# ElixirTwitterBot

Just a silly [Elixir](https://elixir-lang.org/) application to tweet some content and play a little bit with [Twitter's public API](https://developer.twitter.com/en/docs.html).

## What we're going to do?

In this example, we're going to create an [Elixir](https://elixir-lang.org/) application which will contain a series of simple endpoints in order to be able to interact with the bot. Our goal will be to **tweet content in our account**, **get tweets about a topic**, and **retweet a tweet**.

We'll need to install in our computer two main things:

- [Erlang](https://www.erlang.org/): it's the only prerequisite to be able to install [Elixir](https://elixir-lang.org/). You can download and install the latest version in its [download page](https://www.erlang.org/downloads).
- [Elixir](https://elixir-lang.org/): our beloved functional language. You can follow the instructions in its [install guidelines](https://elixir-lang.org/install.html).

Once we have these things installed, you can check that all went well by executing these instructions in your terminal and seeing if you get something like:

```bash
user@computer:$ erl -v
Erlang/OTP 20 [erts-9.2] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:10] [hipe] [kernel-poll:false]

Eshell V9.2  (abort with ^G)
1> _
```

```bash
user@computer:$ elixir -v
Erlang/OTP 20 [erts-9.2] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:10] [hipe] [kernel-poll:false]

Elixir 1.8.1 (compiled with Erlang/OTP 20)
```

If you see something similar to these examples, we'll ready to start, so let's go!

## Creating our application

The first step we need to take is to create the structure of our Elixir application. For that, we're going to use the `mix new` task provided by Elixir. This task will create our new project, specifying a name and an option if we need to. In our case, we're going to specify the `--sup` option, in order to generate an **OTP application** skeleton including a supervision tree. Normally an app is generated without a supervisor and without the app callback.

You can check the complete documentation of `mix new` [here](https://hexdocs.pm/mix/Mix.Tasks.New.html).

So, just type in your terminal:

```bash
user@computer: mix new elixir_twitter_bot --sup
```

and there you have it! Your first Elixir application :smile:

## Adding our dependencies

To build our endpoints, we're going to use [Plug](https://hexdocs.pm/plug/readme.html), using Erlang's [Cowboy](https://github.com/ninenines/cowboy) HTTP server, and [Jason](https://github.com/michalmuskala/jason) as our **JSON** parser.

- **Plug**: a specification for **composable modules** between web applications and connection adapters for different web servers in the **Erlang VM**.
- **Cowboy**: a small, fast and modern **HTTP server** for **Erlang/OTP**. It's a fault tolerant "server for the modern web" supporting **HTTP/2**, providing a suite of handlers for **Websockets** and interfaces for **long-lived connections**.
- **Jason**: a blazing fast **JSON** parser and generator in pure Elixir.

So, in order to add these dependencies, we need to add it to our `mix.exs` file:

```elixir
  defp deps do
    [
      # This will add Plug and Cowboy
      {:plug_cowboy, "~> 2.0"},
      # This will add Jason
      {:jason, "~> 1.1"}
    ]
  end
```

and use `mix deps.get` task to fetch all our dependencies:

```bash
user@computer:/elixir_twitter_bot$ mix deps.get
```

You can check the complete documentation of `mix deps.get` [here](https://hexdocs.pm/mix/Mix.Tasks.Deps.Get.html).

## Adding Plug.Cowboy to our supervisor tree

To start the `Plug.Cowboy` module, we need to add its config information to our supervisor tree inside `lib/elixir_twitter_bot/application.ex`:

```elixir
  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Use Plug.Cowboy.child_spec/3 to register our endpoint as a plug
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: ElixirTwitterBot.Endpoint,
        options: [port: 4000]
      )
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirTwitterBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
```

## Implementing our ElixirTwitterBot.Endpoint

As the first step to complete our application, we're going to create a new module and implement a simple endpoint in order to check if everything its ok. Inside `lib/elixir_twitter_bot` folder, create a file `endpoint.ex` and, with the help of [Plug's official documentation](https://hexdocs.pm/plug), create an endpoint `/ping`, and return just a **Pong!** response.

At the end, your code should look something like this:

```elixir
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
end
```

To check if everything its ok, start the application by using `mix run` task:

```bash
user@computer:/elixir_twitter_bot$ mix run --no-halt
```

Then open a browser and go to `http://localhost:4000/ping`. You should get the right response.

To complete the base of our application, we're going to add two functions to handle our application' errors, and to generate the response for the user:

```elixir
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
```

## Adding ExTwitter to interact with Twitter's public API

We need to add [ExTwitter](https://github.com/parroty/extwitter) as our third dependency in `mix.exs` file:

```elixir
  defp deps do
    [
      # This will add Plug and Cowboy
      {:plug_cowboy, "~> 2.0"},
      # This will add Jason
      {:jason, "~> 1.1"},
      # This will add ExTwitter
      {:extwitter, "~> 0.9"}
    ]
  end
```

Then, go to the [Twitter developers site](https://developer.twitter.com/) and create a new application to get the authorization credentials to interact with **Twitter's API**, and add this information to `congif/config.exs`:

```elixir
# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :extwitter, :oauth,
  consumer_key: "",
  consumer_secret: "",
  access_token: "",
  access_token_secret: ""
```

## Creating the update status endpoint

Let's add the first endpoint to tweet some content to our Twitter's account. For this, add to the main module of the application (`lib/elixir_twitter_bot.ex`) a new function, which will receive a `conn` as an argument, and return the status of the request to the **API**. Your code should look something like this:

```elixir
defmodule ElixirTwitterBot do
  @moduledoc """
  Main module of the ElixirTwitterBot. Here we have some simple functions to
  interact with Twitter's public API through ExTwitter library.
  """
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
end
```

Then add to you endpoint module the new endpoint to use this new function:

```elixir
  # Endpoint to post a new tweet to our Twitter's account
  post "/update" do
    conn
    |> ElixirTwitterBot.update_status()
    |> generate_response(conn)
  end
```

To check if everything its ok, start the application by using `mix run` task:

```bash
user@computer:/elixir_twitter_bot$ mix run --no-halt
```

Then make a `POST` request to `http://localhost:4000/update`, sending any text on the `status` parameter. You should get the right response and see a new tweet in your account :smile:

## Creating the tweet search endpoint

Repeat the same steps, but this time using the `ExTwitter.API.Search.search/2` function from **ExTwitter**:

```elixir
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
```

and in the endpoint module:

```elixir
  # Endpoint to search tweets by a query
  get "/search" do
    conn
    |> ElixirTwitterBot.search()
    |> generate_response(conn)
  end
```
## Creating the retweet endpoint

Repeat the same steps, but this time using the `ExTwitter.API.Tweets.retweet/2` function from **ExTwitter**:

```elixir
  def retweet(%Plug.Conn{body_params: %{"tweet_id" => tweet_id}}) do
    case Tweets.retweet(tweet_id) do
      %ExTwitter.Model.Tweet{id: id} ->
        {:ok, %{id: id, message: "Tweet retweeted succesfully!"}}

      _ ->
        {:error,
         "Something wrong happened. The tweet couldn't be retweeted right now."}
    end
  end
```

and in the endpoint module:

```elixir
  # Endpoint to retweet a tweet to our Twitter's account
  post "/retweet" do
    conn
    |> ElixirTwitterBot.retweet()
    |> generate_response(conn)
  end
```

## Resources

- [Erlang documentation](https://www.erlang.org/docs).
- [Elixir documentation](https://elixir-lang.org/docs.html).
- [Mix documentation](https://hexdocs.pm/mix/Mix.html).
- [Plug documentation](https://hexdocs.pm/plug/readme.html).
- [ExTwitter documentation](https://hexdocs.pm/extwitter/ExTwitter.html).

----------------------------

This project was developed by [dreamingechoes](https://github.com/dreamingechoes). It adheres to its [code of conduct](https://github.com/dreamingechoes/base/blob/master/files/CODE_OF_CONDUCT.md) and [contributing guidelines](https://github.com/dreamingechoes/base/blob/master/files/CONTRIBUTING.md), and uses an equivalent [license](https://github.com/dreamingechoes/base/blob/master/files/LICENSE).
