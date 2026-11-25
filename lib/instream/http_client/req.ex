defmodule Instream.HTTPClient.Req do
  @moduledoc """
  HTTP client using `Req.request/1`.

  Responses are returned as Instream HTTP client tuples with binary bodies.
  Transport and protocol errors are returned as `{:error, exception}` tuples.

  See `Instream.Connection.Config` and `Instream.HTTPClient` if you want to
  replace the client with a library of your choice.
  """

  @behaviour Instream.HTTPClient

  @impl Instream.HTTPClient
  def request(method, url, headers, body, opts) do
    opts =
      [retry: false, redirect: false, compressed: false]
      |> Keyword.merge(opts)
      |> Keyword.merge(method: method, url: url, headers: headers, body: body, raw: true)

    case Req.request(opts) do
      {:ok, response} ->
        headers =
          for {name, values} <- response.headers, value <- List.wrap(values), do: {name, value}

        case method do
          :head -> {:ok, response.status, headers}
          _ -> {:ok, response.status, headers, response.body}
        end

      {:error, _} = error ->
        error
    end
  end
end
