defmodule GriffinWeb.ExchangeLocationLiveTest do
  use GriffinWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Griffin.Exchange

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp fixture(:exchange_location) do
    {:ok, exchange_location} = Exchange.create_exchange_location(@create_attrs)
    exchange_location
  end

  defp create_exchange_location(_) do
    exchange_location = fixture(:exchange_location)
    %{exchange_location: exchange_location}
  end

  describe "Index" do
    setup [:create_exchange_location]

    test "lists all exchange_locations", %{conn: conn, exchange_location: exchange_location} do
      {:ok, _index_live, html} = live(conn, Routes.exchange_location_index_path(conn, :index))

      assert html =~ "Listing Exchange locations"
      assert html =~ exchange_location.name
    end

    test "saves new exchange_location", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.exchange_location_index_path(conn, :index))

      assert index_live |> element("a", "New Exchange location") |> render_click() =~
               "New Exchange location"

      assert_patch(index_live, Routes.exchange_location_index_path(conn, :new))

      assert index_live
             |> form("#exchange_location-form", exchange_location: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#exchange_location-form", exchange_location: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.exchange_location_index_path(conn, :index))

      assert html =~ "Exchange location created successfully"
      assert html =~ "some name"
    end

    test "updates exchange_location in listing", %{conn: conn, exchange_location: exchange_location} do
      {:ok, index_live, _html} = live(conn, Routes.exchange_location_index_path(conn, :index))

      assert index_live |> element("#exchange_location-#{exchange_location.id} a", "Edit") |> render_click() =~
               "Edit Exchange location"

      assert_patch(index_live, Routes.exchange_location_index_path(conn, :edit, exchange_location))

      assert index_live
             |> form("#exchange_location-form", exchange_location: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#exchange_location-form", exchange_location: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.exchange_location_index_path(conn, :index))

      assert html =~ "Exchange location updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes exchange_location in listing", %{conn: conn, exchange_location: exchange_location} do
      {:ok, index_live, _html} = live(conn, Routes.exchange_location_index_path(conn, :index))

      assert index_live |> element("#exchange_location-#{exchange_location.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#exchange_location-#{exchange_location.id}")
    end
  end

  describe "Show" do
    setup [:create_exchange_location]

    test "displays exchange_location", %{conn: conn, exchange_location: exchange_location} do
      {:ok, _show_live, html} = live(conn, Routes.exchange_location_show_path(conn, :show, exchange_location))

      assert html =~ "Show Exchange location"
      assert html =~ exchange_location.name
    end

    test "updates exchange_location within modal", %{conn: conn, exchange_location: exchange_location} do
      {:ok, show_live, _html} = live(conn, Routes.exchange_location_show_path(conn, :show, exchange_location))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Exchange location"

      assert_patch(show_live, Routes.exchange_location_show_path(conn, :edit, exchange_location))

      assert show_live
             |> form("#exchange_location-form", exchange_location: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#exchange_location-form", exchange_location: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.exchange_location_show_path(conn, :show, exchange_location))

      assert html =~ "Exchange location updated successfully"
      assert html =~ "some updated name"
    end
  end
end
