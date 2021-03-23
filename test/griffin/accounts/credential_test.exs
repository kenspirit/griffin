defmodule Griffin.Accounts.CredentialTest do
  use Griffin.DataCase

  alias Griffin.Accounts.Credential

  describe "credential_wechats" do
    alias Griffin.Accounts.Credential.CredentialWechat

    @valid_attrs %{meta: %{}, openid: "some openid", unionid: "some unionid"}
    @update_attrs %{meta: %{}, openid: "some updated openid", unionid: "some updated unionid"}
    @invalid_attrs %{meta: nil, openid: nil, unionid: nil}

    def credential_wechat_fixture(attrs \\ %{}) do
      {:ok, credential_wechat} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Credential.create_credential_wechat()

      credential_wechat
    end

    test "list_credential_wechats/0 returns all credential_wechats" do
      credential_wechat = credential_wechat_fixture()
      assert Credential.list_credential_wechats() == [credential_wechat]
    end

    test "get_credential_wechat!/1 returns the credential_wechat with given id" do
      credential_wechat = credential_wechat_fixture()
      assert Credential.get_credential_wechat!(credential_wechat.id) == credential_wechat
    end

    test "create_credential_wechat/1 with valid data creates a credential_wechat" do
      assert {:ok, %CredentialWechat{} = credential_wechat} = Credential.create_credential_wechat(@valid_attrs)
      assert credential_wechat.meta == %{}
      assert credential_wechat.openid == "some openid"
      assert credential_wechat.unionid == "some unionid"
    end

    test "create_credential_wechat/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Credential.create_credential_wechat(@invalid_attrs)
    end

    test "update_credential_wechat/2 with valid data updates the credential_wechat" do
      credential_wechat = credential_wechat_fixture()
      assert {:ok, %CredentialWechat{} = credential_wechat} = Credential.update_credential_wechat(credential_wechat, @update_attrs)
      assert credential_wechat.meta == %{}
      assert credential_wechat.openid == "some updated openid"
      assert credential_wechat.unionid == "some updated unionid"
    end

    test "update_credential_wechat/2 with invalid data returns error changeset" do
      credential_wechat = credential_wechat_fixture()
      assert {:error, %Ecto.Changeset{}} = Credential.update_credential_wechat(credential_wechat, @invalid_attrs)
      assert credential_wechat == Credential.get_credential_wechat!(credential_wechat.id)
    end

    test "delete_credential_wechat/1 deletes the credential_wechat" do
      credential_wechat = credential_wechat_fixture()
      assert {:ok, %CredentialWechat{}} = Credential.delete_credential_wechat(credential_wechat)
      assert_raise Ecto.NoResultsError, fn -> Credential.get_credential_wechat!(credential_wechat.id) end
    end

    test "change_credential_wechat/1 returns a credential_wechat changeset" do
      credential_wechat = credential_wechat_fixture()
      assert %Ecto.Changeset{} = Credential.change_credential_wechat(credential_wechat)
    end
  end
end
