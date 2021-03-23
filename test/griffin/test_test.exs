defmodule Griffin.TestTest do
  use Griffin.DataCase

  alias Griffin.Test

  describe "test_locations" do
    alias Griffin.Test.TestLocation

    @valid_attrs %{code: "some code", enname: "some enname", name: "some name"}
    @update_attrs %{code: "some updated code", enname: "some updated enname", name: "some updated name"}
    @invalid_attrs %{code: nil, enname: nil, name: nil}

    def test_location_fixture(attrs \\ %{}) do
      {:ok, test_location} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Test.create_test_location()

      test_location
    end

    test "list_test_locations/0 returns all test_locations" do
      test_location = test_location_fixture()
      assert Test.list_test_locations() == [test_location]
    end

    test "get_test_location!/1 returns the test_location with given id" do
      test_location = test_location_fixture()
      assert Test.get_test_location!(test_location.id) == test_location
    end

    test "create_test_location/1 with valid data creates a test_location" do
      assert {:ok, %TestLocation{} = test_location} = Test.create_test_location(@valid_attrs)
      assert test_location.code == "some code"
      assert test_location.enname == "some enname"
      assert test_location.name == "some name"
    end

    test "create_test_location/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Test.create_test_location(@invalid_attrs)
    end

    test "update_test_location/2 with valid data updates the test_location" do
      test_location = test_location_fixture()
      assert {:ok, %TestLocation{} = test_location} = Test.update_test_location(test_location, @update_attrs)
      assert test_location.code == "some updated code"
      assert test_location.enname == "some updated enname"
      assert test_location.name == "some updated name"
    end

    test "update_test_location/2 with invalid data returns error changeset" do
      test_location = test_location_fixture()
      assert {:error, %Ecto.Changeset{}} = Test.update_test_location(test_location, @invalid_attrs)
      assert test_location == Test.get_test_location!(test_location.id)
    end

    test "delete_test_location/1 deletes the test_location" do
      test_location = test_location_fixture()
      assert {:ok, %TestLocation{}} = Test.delete_test_location(test_location)
      assert_raise Ecto.NoResultsError, fn -> Test.get_test_location!(test_location.id) end
    end

    test "change_test_location/1 returns a test_location changeset" do
      test_location = test_location_fixture()
      assert %Ecto.Changeset{} = Test.change_test_location(test_location)
    end
  end
end
