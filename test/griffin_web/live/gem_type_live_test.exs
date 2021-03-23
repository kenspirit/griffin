defmodule GriffinWeb.GemTypeLiveTest do
  use GriffinWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Griffin.Treasure

  @create_attrs %{code: "some code", name: "some name"}
  @update_attrs %{code: "some updated code", name: "some updated name"}
  @invalid_attrs %{code: nil, name: nil}

  defp fixture(:gem_type) do
    {:ok, gem_type} = Treasure.create_gem_type(@create_attrs)
    gem_type
  end

  defp create_gem_type(_) do
    gem_type = fixture(:gem_type)
    %{gem_type: gem_type}
  end

  describe "Index" do
    setup [:create_gem_type]

    test "lists all gem_types", %{conn: conn, gem_type: gem_type} do
      {:ok, _index_live, html} = live(conn, Routes.gem_type_index_path(conn, :index))

      assert html =~ "Listing Gem types"
      assert html =~ gem_type.code
    end

    test "saves new gem_type", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.gem_type_index_path(conn, :index))

      assert index_live |> element("a", "New Gem type") |> render_click() =~
               "New Gem type"

      assert_patch(index_live, Routes.gem_type_index_path(conn, :new))

      assert index_live
             |> form("#gem_type-form", gem_type: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#gem_type-form", gem_type: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.gem_type_index_path(conn, :index))

      assert html =~ "Gem type created successfully"
      assert html =~ "some code"
    end

    test "updates gem_type in listing", %{conn: conn, gem_type: gem_type} do
      {:ok, index_live, _html} = live(conn, Routes.gem_type_index_path(conn, :index))

      assert index_live |> element("#gem_type-#{gem_type.id} a", "Edit") |> render_click() =~
               "Edit Gem type"

      assert_patch(index_live, Routes.gem_type_index_path(conn, :edit, gem_type))

      assert index_live
             |> form("#gem_type-form", gem_type: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#gem_type-form", gem_type: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.gem_type_index_path(conn, :index))

      assert html =~ "Gem type updated successfully"
      assert html =~ "some updated code"
    end

    test "deletes gem_type in listing", %{conn: conn, gem_type: gem_type} do
      {:ok, index_live, _html} = live(conn, Routes.gem_type_index_path(conn, :index))

      assert index_live |> element("#gem_type-#{gem_type.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#gem_type-#{gem_type.id}")
    end
  end

  describe "Show" do
    setup [:create_gem_type]

    test "displays gem_type", %{conn: conn, gem_type: gem_type} do
      {:ok, _show_live, html} = live(conn, Routes.gem_type_show_path(conn, :show, gem_type))

      assert html =~ "Show Gem type"
      assert html =~ gem_type.code
    end

    test "updates gem_type within modal", %{conn: conn, gem_type: gem_type} do
      {:ok, show_live, _html} = live(conn, Routes.gem_type_show_path(conn, :show, gem_type))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Gem type"

      assert_patch(show_live, Routes.gem_type_show_path(conn, :edit, gem_type))

      assert show_live
             |> form("#gem_type-form", gem_type: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#gem_type-form", gem_type: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.gem_type_show_path(conn, :show, gem_type))

      assert html =~ "Gem type updated successfully"
      assert html =~ "some updated code"
    end
  end
end
