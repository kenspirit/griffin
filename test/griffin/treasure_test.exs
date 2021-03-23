defmodule Griffin.TreasureTest do
  use Griffin.DataCase

  alias Griffin.Treasure

  describe "gems" do
    alias Griffin.Treasure.Gem

    @valid_attrs %{name: "some name", type: "some type"}
    @update_attrs %{name: "some updated name", type: "some updated type"}
    @invalid_attrs %{name: nil, type: nil}

    def gem_fixture(attrs \\ %{}) do
      {:ok, gem} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Treasure.create_gem()

      gem
    end

    test "list_gems/0 returns all gems" do
      gem = gem_fixture()
      assert Treasure.list_gems() == [gem]
    end

    test "get_gem!/1 returns the gem with given id" do
      gem = gem_fixture()
      assert Treasure.get_gem!(gem.id) == gem
    end

    test "create_gem/1 with valid data creates a gem" do
      assert {:ok, %Gem{} = gem} = Treasure.create_gem(@valid_attrs)
      assert gem.name == "some name"
      assert gem.type == "some type"
    end

    test "create_gem/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Treasure.create_gem(@invalid_attrs)
    end

    test "update_gem/2 with valid data updates the gem" do
      gem = gem_fixture()
      assert {:ok, %Gem{} = gem} = Treasure.update_gem(gem, @update_attrs)
      assert gem.name == "some updated name"
      assert gem.type == "some updated type"
    end

    test "update_gem/2 with invalid data returns error changeset" do
      gem = gem_fixture()
      assert {:error, %Ecto.Changeset{}} = Treasure.update_gem(gem, @invalid_attrs)
      assert gem == Treasure.get_gem!(gem.id)
    end

    test "delete_gem/1 deletes the gem" do
      gem = gem_fixture()
      assert {:ok, %Gem{}} = Treasure.delete_gem(gem)
      assert_raise Ecto.NoResultsError, fn -> Treasure.get_gem!(gem.id) end
    end

    test "change_gem/1 returns a gem changeset" do
      gem = gem_fixture()
      assert %Ecto.Changeset{} = Treasure.change_gem(gem)
    end
  end

  describe "gems" do
    alias Griffin.Treasure.Gem

    @valid_attrs %{amount: 42, name: "some name", price: "120.5", type: "some type"}
    @update_attrs %{amount: 43, name: "some updated name", price: "456.7", type: "some updated type"}
    @invalid_attrs %{amount: nil, name: nil, price: nil, type: nil}

    def gem_fixture(attrs \\ %{}) do
      {:ok, gem} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Treasure.create_gem()

      gem
    end

    test "list_gems/0 returns all gems" do
      gem = gem_fixture()
      assert Treasure.list_gems() == [gem]
    end

    test "get_gem!/1 returns the gem with given id" do
      gem = gem_fixture()
      assert Treasure.get_gem!(gem.id) == gem
    end

    test "create_gem/1 with valid data creates a gem" do
      assert {:ok, %Gem{} = gem} = Treasure.create_gem(@valid_attrs)
      assert gem.amount == 42
      assert gem.name == "some name"
      assert gem.price == Decimal.new("120.5")
      assert gem.type == "some type"
    end

    test "create_gem/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Treasure.create_gem(@invalid_attrs)
    end

    test "update_gem/2 with valid data updates the gem" do
      gem = gem_fixture()
      assert {:ok, %Gem{} = gem} = Treasure.update_gem(gem, @update_attrs)
      assert gem.amount == 43
      assert gem.name == "some updated name"
      assert gem.price == Decimal.new("456.7")
      assert gem.type == "some updated type"
    end

    test "update_gem/2 with invalid data returns error changeset" do
      gem = gem_fixture()
      assert {:error, %Ecto.Changeset{}} = Treasure.update_gem(gem, @invalid_attrs)
      assert gem == Treasure.get_gem!(gem.id)
    end

    test "delete_gem/1 deletes the gem" do
      gem = gem_fixture()
      assert {:ok, %Gem{}} = Treasure.delete_gem(gem)
      assert_raise Ecto.NoResultsError, fn -> Treasure.get_gem!(gem.id) end
    end

    test "change_gem/1 returns a gem changeset" do
      gem = gem_fixture()
      assert %Ecto.Changeset{} = Treasure.change_gem(gem)
    end
  end

  describe "locations" do
    alias Griffin.Treasure.Location

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def location_fixture(attrs \\ %{}) do
      {:ok, location} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Treasure.create_location()

      location
    end

    test "list_locations/0 returns all locations" do
      location = location_fixture()
      assert Treasure.list_locations() == [location]
    end

    test "get_location!/1 returns the location with given id" do
      location = location_fixture()
      assert Treasure.get_location!(location.id) == location
    end

    test "create_location/1 with valid data creates a location" do
      assert {:ok, %Location{} = location} = Treasure.create_location(@valid_attrs)
      assert location.name == "some name"
    end

    test "create_location/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Treasure.create_location(@invalid_attrs)
    end

    test "update_location/2 with valid data updates the location" do
      location = location_fixture()
      assert {:ok, %Location{} = location} = Treasure.update_location(location, @update_attrs)
      assert location.name == "some updated name"
    end

    test "update_location/2 with invalid data returns error changeset" do
      location = location_fixture()
      assert {:error, %Ecto.Changeset{}} = Treasure.update_location(location, @invalid_attrs)
      assert location == Treasure.get_location!(location.id)
    end

    test "delete_location/1 deletes the location" do
      location = location_fixture()
      assert {:ok, %Location{}} = Treasure.delete_location(location)
      assert_raise Ecto.NoResultsError, fn -> Treasure.get_location!(location.id) end
    end

    test "change_location/1 returns a location changeset" do
      location = location_fixture()
      assert %Ecto.Changeset{} = Treasure.change_location(location)
    end
  end

  describe "gem_types" do
    alias Griffin.Treasure.GemType

    @valid_attrs %{code: "some code", name: "some name"}
    @update_attrs %{code: "some updated code", name: "some updated name"}
    @invalid_attrs %{code: nil, name: nil}

    def gem_type_fixture(attrs \\ %{}) do
      {:ok, gem_type} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Treasure.create_gem_type()

      gem_type
    end

    test "list_gem_types/0 returns all gem_types" do
      gem_type = gem_type_fixture()
      assert Treasure.list_gem_types() == [gem_type]
    end

    test "get_gem_type!/1 returns the gem_type with given id" do
      gem_type = gem_type_fixture()
      assert Treasure.get_gem_type!(gem_type.id) == gem_type
    end

    test "create_gem_type/1 with valid data creates a gem_type" do
      assert {:ok, %GemType{} = gem_type} = Treasure.create_gem_type(@valid_attrs)
      assert gem_type.code == "some code"
      assert gem_type.name == "some name"
    end

    test "create_gem_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Treasure.create_gem_type(@invalid_attrs)
    end

    test "update_gem_type/2 with valid data updates the gem_type" do
      gem_type = gem_type_fixture()
      assert {:ok, %GemType{} = gem_type} = Treasure.update_gem_type(gem_type, @update_attrs)
      assert gem_type.code == "some updated code"
      assert gem_type.name == "some updated name"
    end

    test "update_gem_type/2 with invalid data returns error changeset" do
      gem_type = gem_type_fixture()
      assert {:error, %Ecto.Changeset{}} = Treasure.update_gem_type(gem_type, @invalid_attrs)
      assert gem_type == Treasure.get_gem_type!(gem_type.id)
    end

    test "delete_gem_type/1 deletes the gem_type" do
      gem_type = gem_type_fixture()
      assert {:ok, %GemType{}} = Treasure.delete_gem_type(gem_type)
      assert_raise Ecto.NoResultsError, fn -> Treasure.get_gem_type!(gem_type.id) end
    end

    test "change_gem_type/1 returns a gem_type changeset" do
      gem_type = gem_type_fixture()
      assert %Ecto.Changeset{} = Treasure.change_gem_type(gem_type)
    end
  end
end
