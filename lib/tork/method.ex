defmodule Tork.Method do
  require Logger
  @moduledoc """
  Modules that parses the data sent by client, return messages related
  to commands and runs the command.
  """

  @doc ~S"""
  Parses the given `data` into command.
  """
  @methods %{"GET" => :get,
             "PUT" => :put,
             "HEAD" => :head,
             "POST" => :post,
             "DELETE" => :delete,
             "OPTIONS" => :options,
             "TRACE" => :trace,
             "CONNECT" => :connect}
  def parse(data) do
    Logger.info("Message recieved: #{data}")
    [method, resource, version] = String.split(data)
    if Map.get(@methods, method) do
      {:ok, {Map.get(@methods, method), resource, version}}
    else
      {:error, {:unknown_command, version}}
    end
  end

  @doc """
  Runs the given `command`.
  """
  def run(command)

  def run({:get, resource, version}) do
    web_directory = Tork.Map.get(Tork.Map, "web_directory")
    resource = String.replace(resource, "../", "")
    case File.read("./#{web_directory}#{resource}") do
      {:ok, body} -> {:ok, version, body}
      {:error, _} -> {:http_error, version, 404}
    end
  end

  def run({:put, resource, version}) do
    Logger.info("Got PUT request for #{resource} with #{version}")
  end

  def run({:head, resource, version}) do
    Logger.info("Got HEAD request for #{resource} with #{version}")
  end

  def run({:post, resource, version}) do
    Logger.info("Got POST request for #{resource} with #{version}")
  end

  def run({:delete, resource, version}) do
    Logger.info("Got DELETE request for #{resource} with #{version}")
  end

  def run({:options, resource, version}) do
    Logger.info("Got OPTIONS request for #{resource} with #{version}")
  end

  def run({:trace, resource, version}) do
    Logger.info("Got TRACE request for #{resource} with #{version}")
  end

  def run({:connect, resource, version}) do
    Logger.info("Got CONNECT request for #{resource} with #{version}")
  end
end
