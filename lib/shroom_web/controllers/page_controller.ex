defmodule ShroomWeb.PageController do
  use ShroomWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
