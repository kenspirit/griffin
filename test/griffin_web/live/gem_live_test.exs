defmodule GriffinWeb.GemLiveTest do
  use GriffinWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Griffin.Treasure

  @create_attrs %{amount: 42, name: "some name", price: "120.5", type: "some type"}
  @update_attrs %{amount: 43, name: "some updated name", price: "456.7", type: "some updated type"}
  @invalid_attrs %{amount: nil, name: nil, price: nil, type: nil}

  defp fixture(:gem) do
    {:ok, gem} = Treasure.create_gem(@create_attrs)
    gem
  end

  defp create_gem(_) do
    gem = fixture(:gem)
    %{gem: gem}
  end

  describe "Index" do
    setup [:create_gem]

    test "lists all gems", %{conn: conn, gem: gem} do
      {:ok, _index_live, html} = live(conn, Routes.gem_index_path(conn, :index))

      assert html =~ "Listing Gems"
      assert html =~ gem.name
    end

    test "saves new gem", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.gem_index_path(conn, :index))

      assert index_live |> element("a", "New Gem") |> render_click() =~
               "New Gem"

      assert_patch(index_live, Routes.gem_index_path(conn, :new))

      assert index_live
             |> form("#gem-form", gem: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#gem-form", gem: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.gem_index_path(conn, :index))

      assert html =~ "Gem created successfully"
      assert html =~ "some name"
    end

    test "updates gem in listing", %{conn: conn, gem: gem} do
      {:ok, index_live, _html} = live(conn, Routes.gem_index_path(conn, :index))

      assert index_live |> element("#gem-#{gem.id} a", "Edit") |> render_click() =~
               "Edit Gem"

      assert_patch(index_live, Routes.gem_index_path(conn, :edit, gem))

      assert index_live
             |> form("#gem-form", gem: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#gem-form", gem: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.gem_index_path(conn, :index))

      assert html =~ "Gem updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes gem in listing", %{conn: conn, gem: gem} do
      {:ok, index_live, _html} = live(conn, Routes.gem_index_path(conn, :index))

      assert index_live |> element("#gem-#{gem.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#gem-#{gem.id}")
    end
  end

  describe "Show" do
    setup [:create_gem]

    test "displays gem", %{conn: conn, gem: gem} do
      {:ok, _show_live, html} = live(conn, Routes.gem_show_path(conn, :show, gem))

      assert html =~ "Show Gem"
      assert html =~ gem.name
    end

    test "updates gem within modal", %{conn: conn, gem: gem} do
      {:ok, show_live, _html} = live(conn, Routes.gem_show_path(conn, :show, gem))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Gem"

      assert_patch(show_live, Routes.gem_show_path(conn, :edit, gem))

      assert show_live
             |> form("#gem-form", gem: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#gem-form", gem: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.gem_show_path(conn, :show, gem))

      assert html =~ "Gem updated successfully"
      assert html =~ "some updated name"
    end
  end
end
