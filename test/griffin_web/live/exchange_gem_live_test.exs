defmodule GriffinWeb.ExchangeGemLiveTest do
  use GriffinWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Griffin.Exchange

  @create_attrs %{amount: 42, price: "120.5"}
  @update_attrs %{amount: 43, price: "456.7"}
  @invalid_attrs %{amount: nil, price: nil}

  defp fixture(:exchange_gem) do
    {:ok, exchange_gem} = Exchange.create_exchange_gem(@create_attrs)
    exchange_gem
  end

  defp create_exchange_gem(_) do
    exchange_gem = fixture(:exchange_gem)
    %{exchange_gem: exchange_gem}
  end

  describe "Index" do
    setup [:create_exchange_gem]

    test "lists all exchange_gems", %{conn: conn, exchange_gem: exchange_gem} do
      {:ok, _index_live, html} = live(conn, Routes.exchange_gem_index_path(conn, :index))

      assert html =~ "Listing Exchange gems"
    end

    test "saves new exchange_gem", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.exchange_gem_index_path(conn, :index))

      assert index_live |> element("a", "New Exchange gem") |> render_click() =~
               "New Exchange gem"

      assert_patch(index_live, Routes.exchange_gem_index_path(conn, :new))

      assert index_live
             |> form("#exchange_gem-form", exchange_gem: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#exchange_gem-form", exchange_gem: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.exchange_gem_index_path(conn, :index))

      assert html =~ "Exchange gem created successfully"
    end

    test "updates exchange_gem in listing", %{conn: conn, exchange_gem: exchange_gem} do
      {:ok, index_live, _html} = live(conn, Routes.exchange_gem_index_path(conn, :index))

      assert index_live |> element("#exchange_gem-#{exchange_gem.id} a", "Edit") |> render_click() =~
               "Edit Exchange gem"

      assert_patch(index_live, Routes.exchange_gem_index_path(conn, :edit, exchange_gem))

      assert index_live
             |> form("#exchange_gem-form", exchange_gem: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#exchange_gem-form", exchange_gem: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.exchange_gem_index_path(conn, :index))

      assert html =~ "Exchange gem updated successfully"
    end

    test "deletes exchange_gem in listing", %{conn: conn, exchange_gem: exchange_gem} do
      {:ok, index_live, _html} = live(conn, Routes.exchange_gem_index_path(conn, :index))

      assert index_live |> element("#exchange_gem-#{exchange_gem.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#exchange_gem-#{exchange_gem.id}")
    end
  end

  describe "Show" do
    setup [:create_exchange_gem]

    test "displays exchange_gem", %{conn: conn, exchange_gem: exchange_gem} do
      {:ok, _show_live, html} = live(conn, Routes.exchange_gem_show_path(conn, :show, exchange_gem))

      assert html =~ "Show Exchange gem"
    end

    test "updates exchange_gem within modal", %{conn: conn, exchange_gem: exchange_gem} do
      {:ok, show_live, _html} = live(conn, Routes.exchange_gem_show_path(conn, :show, exchange_gem))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Exchange gem"

      assert_patch(show_live, Routes.exchange_gem_show_path(conn, :edit, exchange_gem))

      assert show_live
             |> form("#exchange_gem-form", exchange_gem: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#exchange_gem-form", exchange_gem: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.exchange_gem_show_path(conn, :show, exchange_gem))

      assert html =~ "Exchange gem updated successfully"
    end
  end
end
