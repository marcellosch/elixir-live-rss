defmodule RssLiveWeb.LiveController do
  use RssLiveWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end

  def submit_url(conn, %{"url" => url}) do
    RssLive.RssServer.start_link(url)
    redirect(conn, to: ~p"/live/#{url}")
  end

  def show(conn, %{"feed_id" => feed_id}) do
    render(conn, :show, feed_id: feed_id)
  end
end
