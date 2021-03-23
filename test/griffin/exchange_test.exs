defmodule Griffin.ExchangeTest do
  use Griffin.DataCase

  alias Griffin.Exchange

  describe "gem_exchanges" do
    alias Griffin.Exchange.LocationExchange

    @valid_attrs %{amount: 42, createdAt: "2010-04-17T14:00:00Z", location: "some location", price: "120.5"}
    @update_attrs %{amount: 43, createdAt: "2011-05-18T15:01:01Z", location: "some updated location", price: "456.7"}
    @invalid_attrs %{amount: nil, createdAt: nil, location: nil, price: nil}

    def gem_exchange_fixture(attrs \\ %{}) do
      {:ok, gem_exchange} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Exchange.create_gem_exchange()

      gem_exchange
    end

    test "list_gem_exchanges/0 returns all gem_exchanges" do
      gem_exchange = gem_exchange_fixture()
      assert Exchange.list_gem_exchanges() == [gem_exchange]
    end

    test "get_gem_exchange!/1 returns the gem_exchange with given id" do
      gem_exchange = gem_exchange_fixture()
      assert Exchange.get_gem_exchange!(gem_exchange.id) == gem_exchange
    end

    test "create_gem_exchange/1 with valid data creates a gem_exchange" do
      assert {:ok, %GemExchange{} = gem_exchange} = Exchange.create_gem_exchange(@valid_attrs)
      assert gem_exchange.amount == 42
      assert gem_exchange.createdAt == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert gem_exchange.location == "some location"
      assert gem_exchange.price == Decimal.new("120.5")
    end

    test "create_gem_exchange/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Exchange.create_gem_exchange(@invalid_attrs)
    end

    test "update_gem_exchange/2 with valid data updates the gem_exchange" do
      gem_exchange = gem_exchange_fixture()
      assert {:ok, %GemExchange{} = gem_exchange} = Exchange.update_gem_exchange(gem_exchange, @update_attrs)
      assert gem_exchange.amount == 43
      assert gem_exchange.createdAt == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert gem_exchange.location == "some updated location"
      assert gem_exchange.price == Decimal.new("456.7")
    end

    test "update_gem_exchange/2 with invalid data returns error changeset" do
      gem_exchange = gem_exchange_fixture()
      assert {:error, %Ecto.Changeset{}} = Exchange.update_gem_exchange(gem_exchange, @invalid_attrs)
      assert gem_exchange == Exchange.get_gem_exchange!(gem_exchange.id)
    end

    test "delete_gem_exchange/1 deletes the gem_exchange" do
      gem_exchange = gem_exchange_fixture()
      assert {:ok, %GemExchange{}} = Exchange.delete_gem_exchange(gem_exchange)
      assert_raise Ecto.NoResultsError, fn -> Exchange.get_gem_exchange!(gem_exchange.id) end
    end

    test "change_gem_exchange/1 returns a gem_exchange changeset" do
      gem_exchange = gem_exchange_fixture()
      assert %Ecto.Changeset{} = Exchange.change_gem_exchange(gem_exchange)
    end
  end

  describe "gem_exchange_locations" do
    alias Griffin.Exchange.Location

    @valid_attrs %{createdAt: "2010-04-17T14:00:00Z", name: "some name"}
    @update_attrs %{createdAt: "2011-05-18T15:01:01Z", name: "some updated name"}
    @invalid_attrs %{createdAt: nil, name: nil}

    def gem_exchange_location_fixture(attrs \\ %{}) do
      {:ok, gem_exchange_location} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Exchange.create_gem_exchange_location()

      gem_exchange_location
    end

    test "list_gem_exchange_locations/0 returns all gem_exchange_locations" do
      gem_exchange_location = gem_exchange_location_fixture()
      assert Exchange.list_gem_exchange_locations() == [gem_exchange_location]
    end

    test "get_gem_exchange_location!/1 returns the gem_exchange_location with given id" do
      gem_exchange_location = gem_exchange_location_fixture()
      assert Exchange.get_gem_exchange_location!(gem_exchange_location.id) == gem_exchange_location
    end

    test "create_gem_exchange_location/1 with valid data creates a gem_exchange_location" do
      assert {:ok, %GemExchangeLocation{} = gem_exchange_location} = Exchange.create_gem_exchange_location(@valid_attrs)
      assert gem_exchange_location.createdAt == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert gem_exchange_location.name == "some name"
    end

    test "create_gem_exchange_location/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Exchange.create_gem_exchange_location(@invalid_attrs)
    end

    test "update_gem_exchange_location/2 with valid data updates the gem_exchange_location" do
      gem_exchange_location = gem_exchange_location_fixture()
      assert {:ok, %GemExchangeLocation{} = gem_exchange_location} = Exchange.update_gem_exchange_location(gem_exchange_location, @update_attrs)
      assert gem_exchange_location.createdAt == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert gem_exchange_location.name == "some updated name"
    end

    test "update_gem_exchange_location/2 with invalid data returns error changeset" do
      gem_exchange_location = gem_exchange_location_fixture()
      assert {:error, %Ecto.Changeset{}} = Exchange.update_gem_exchange_location(gem_exchange_location, @invalid_attrs)
      assert gem_exchange_location == Exchange.get_gem_exchange_location!(gem_exchange_location.id)
    end

    test "delete_gem_exchange_location/1 deletes the gem_exchange_location" do
      gem_exchange_location = gem_exchange_location_fixture()
      assert {:ok, %GemExchangeLocation{}} = Exchange.delete_gem_exchange_location(gem_exchange_location)
      assert_raise Ecto.NoResultsError, fn -> Exchange.get_gem_exchange_location!(gem_exchange_location.id) end
    end

    test "change_gem_exchange_location/1 returns a gem_exchange_location changeset" do
      gem_exchange_location = gem_exchange_location_fixture()
      assert %Ecto.Changeset{} = Exchange.change_gem_exchange_location(gem_exchange_location)
    end
  end

  describe "exchange_locations" do
    alias Griffin.Exchange.ExchangeLocation

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def exchange_location_fixture(attrs \\ %{}) do
      {:ok, exchange_location} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Exchange.create_exchange_location()

      exchange_location
    end

    test "list_exchange_locations/0 returns all exchange_locations" do
      exchange_location = exchange_location_fixture()
      assert Exchange.list_exchange_locations() == [exchange_location]
    end

    test "get_exchange_location!/1 returns the exchange_location with given id" do
      exchange_location = exchange_location_fixture()
      assert Exchange.get_exchange_location!(exchange_location.id) == exchange_location
    end

    test "create_exchange_location/1 with valid data creates a exchange_location" do
      assert {:ok, %ExchangeLocation{} = exchange_location} = Exchange.create_exchange_location(@valid_attrs)
      assert exchange_location.name == "some name"
    end

    test "create_exchange_location/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Exchange.create_exchange_location(@invalid_attrs)
    end

    test "update_exchange_location/2 with valid data updates the exchange_location" do
      exchange_location = exchange_location_fixture()
      assert {:ok, %ExchangeLocation{} = exchange_location} = Exchange.update_exchange_location(exchange_location, @update_attrs)
      assert exchange_location.name == "some updated name"
    end

    test "update_exchange_location/2 with invalid data returns error changeset" do
      exchange_location = exchange_location_fixture()
      assert {:error, %Ecto.Changeset{}} = Exchange.update_exchange_location(exchange_location, @invalid_attrs)
      assert exchange_location == Exchange.get_exchange_location!(exchange_location.id)
    end

    test "delete_exchange_location/1 deletes the exchange_location" do
      exchange_location = exchange_location_fixture()
      assert {:ok, %ExchangeLocation{}} = Exchange.delete_exchange_location(exchange_location)
      assert_raise Ecto.NoResultsError, fn -> Exchange.get_exchange_location!(exchange_location.id) end
    end

    test "change_exchange_location/1 returns a exchange_location changeset" do
      exchange_location = exchange_location_fixture()
      assert %Ecto.Changeset{} = Exchange.change_exchange_location(exchange_location)
    end
  end

  describe "exchange_gems" do
    alias Griffin.Exchange.ExchangeGem

    @valid_attrs %{amount: 42, price: "120.5"}
    @update_attrs %{amount: 43, price: "456.7"}
    @invalid_attrs %{amount: nil, price: nil}

    def exchange_gem_fixture(attrs \\ %{}) do
      {:ok, exchange_gem} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Exchange.create_exchange_gem()

      exchange_gem
    end

    test "list_exchange_gems/0 returns all exchange_gems" do
      exchange_gem = exchange_gem_fixture()
      assert Exchange.list_exchange_gems() == [exchange_gem]
    end

    test "get_exchange_gem!/1 returns the exchange_gem with given id" do
      exchange_gem = exchange_gem_fixture()
      assert Exchange.get_exchange_gem!(exchange_gem.id) == exchange_gem
    end

    test "create_exchange_gem/1 with valid data creates a exchange_gem" do
      assert {:ok, %ExchangeGem{} = exchange_gem} = Exchange.create_exchange_gem(@valid_attrs)
      assert exchange_gem.amount == 42
      assert exchange_gem.price == Decimal.new("120.5")
    end

    test "create_exchange_gem/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Exchange.create_exchange_gem(@invalid_attrs)
    end

    test "update_exchange_gem/2 with valid data updates the exchange_gem" do
      exchange_gem = exchange_gem_fixture()
      assert {:ok, %ExchangeGem{} = exchange_gem} = Exchange.update_exchange_gem(exchange_gem, @update_attrs)
      assert exchange_gem.amount == 43
      assert exchange_gem.price == Decimal.new("456.7")
    end

    test "update_exchange_gem/2 with invalid data returns error changeset" do
      exchange_gem = exchange_gem_fixture()
      assert {:error, %Ecto.Changeset{}} = Exchange.update_exchange_gem(exchange_gem, @invalid_attrs)
      assert exchange_gem == Exchange.get_exchange_gem!(exchange_gem.id)
    end

    test "delete_exchange_gem/1 deletes the exchange_gem" do
      exchange_gem = exchange_gem_fixture()
      assert {:ok, %ExchangeGem{}} = Exchange.delete_exchange_gem(exchange_gem)
      assert_raise Ecto.NoResultsError, fn -> Exchange.get_exchange_gem!(exchange_gem.id) end
    end

    test "change_exchange_gem/1 returns a exchange_gem changeset" do
      exchange_gem = exchange_gem_fixture()
      assert %Ecto.Changeset{} = Exchange.change_exchange_gem(exchange_gem)
    end
  end
end
