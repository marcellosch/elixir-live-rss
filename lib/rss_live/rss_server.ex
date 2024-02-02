defmodule RssLive.RssServer do
  use GenServer
  require Logger
  alias Phoenix.PubSub

  # Client API
  def start_link(url) when is_binary(url), do: GenServer.start_link(__MODULE__, url, name: via_url(url))
  def read(pid), do: GenServer.call(pid, :read)

  # Server Callbacks
  @impl true
  def init(url) do
    state = %{url: url, feed: MapSet.new()}
    Logger.info("Initialized RSS server for #{url}")
    schedule_refresh()
    {:ok, state}
  end

  @impl true
  def handle_call(:read, _from, state), do: {:reply, sort_feed(state.feed), state}

  @impl true
  def handle_cast(:refresh, %{url: url, feed: feed} = state) do
    case fetch_rss_feed(url) do
      {:ok, rss_response} -> process_rss_response(rss_response, feed, state)
      {:error, :failed_to_fetch_rss} ->
        Logger.error("Failed to refresh feed for #{url}")
        {:noreply, state}
    end
  end

  @impl true
  def handle_info(:refresh, state) do
    GenServer.cast(self(), :refresh)
    schedule_refresh()
    {:noreply, state}
  end

  # Private helpers
  defp process_rss_response(rss_response, feed, state) do
    new_entries = MapSet.difference(rss_response, feed)
    case MapSet.size(new_entries) do
      0 ->
        log_no_new_entries()
        {:noreply, state}
      _ ->
        log_new_entries_added(new_entries)
        new_state = update_feed_state(state, new_entries)
        broadcast_feed_update(new_state)
        {:noreply, new_state}
    end
  end

  defp log_no_new_entries do
    Logger.info("No new entries")
  end

  defp log_new_entries_added(new_entries) do
    Logger.info("Added new #{MapSet.size(new_entries)} entries")
  end

  defp update_feed_state(state, new_entries) do
    %{state | feed: MapSet.union(state.feed, new_entries)}
  end


  defp schedule_refresh() do
    Process.send_after(self(), :refresh, 2_000)
  end

  defp via_url(url) do
    {:via, Registry, {Registry.RssRegistry, url}}
  end

  defp broadcast_feed_update(%{url: url, feed: feed}) do
    sorted_feed = sort_feed(MapSet.to_list(feed))
    PubSub.broadcast(RssLive.PubSub, url, {:refresh, sorted_feed})
  end

  defp fetch_rss_feed(url) do
    case Feedex.fetch_and_parse url do
      {:ok, rss_response} -> {:ok, MapSet.new(rss_response.entries)}
      {:error, error} ->
        log_rss_fetch_error(error)
        {:error, :failed_to_fetch_rss}
    end
  end

  defp log_rss_fetch_error(error) do
    Logger.info("[RSS Fetch Error] #{error}")
  end

  defp sort_feed(feed) do
    Enum.sort(feed, fn x, y -> x.updated > y.updated end)
  end

end
