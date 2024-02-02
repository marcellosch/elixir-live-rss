defmodule RssLiveWeb.ErrorJSONTest do
  use RssLiveWeb.ConnCase, async: true

  test "renders 404" do
    assert RssLiveWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert RssLiveWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
