defmodule Decibel.PageController do
  use Decibel.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
