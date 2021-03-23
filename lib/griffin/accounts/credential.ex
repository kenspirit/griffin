defmodule Griffin.Accounts.Credential do
  @moduledoc """
  The Accounts.Credential context.
  """

  import Ecto.Query, warn: false
  alias Griffin.Repo

  alias Griffin.Accounts.Credential.CredentialWechat

  @doc """
  Returns the list of credential_wechats.

  ## Examples

      iex> list_credential_wechats()
      [%CredentialWechat{}, ...]

  """
  def list_credential_wechats do
    Repo.all(CredentialWechat)
  end

  @doc """
  Gets a single credential_wechat.

  Raises `Ecto.NoResultsError` if the Credential wechat does not exist.

  ## Examples

      iex> get_credential_wechat!(123)
      %CredentialWechat{}

      iex> get_credential_wechat!(456)
      ** (Ecto.NoResultsError)

  """
  def get_credential_wechat!(id), do: Repo.get!(CredentialWechat, id)

  @doc """
  Creates a credential_wechat.

  ## Examples

      iex> create_credential_wechat(%{field: value})
      {:ok, %CredentialWechat{}}

      iex> create_credential_wechat(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_credential_wechat(attrs \\ %{}) do
    %CredentialWechat{}
    |> CredentialWechat.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a credential_wechat.

  ## Examples

      iex> update_credential_wechat(credential_wechat, %{field: new_value})
      {:ok, %CredentialWechat{}}

      iex> update_credential_wechat(credential_wechat, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_credential_wechat(%CredentialWechat{} = credential_wechat, attrs) do
    credential_wechat
    |> CredentialWechat.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a credential_wechat.

  ## Examples

      iex> delete_credential_wechat(credential_wechat)
      {:ok, %CredentialWechat{}}

      iex> delete_credential_wechat(credential_wechat)
      {:error, %Ecto.Changeset{}}

  """
  def delete_credential_wechat(%CredentialWechat{} = credential_wechat) do
    Repo.delete(credential_wechat)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking credential_wechat changes.

  ## Examples

      iex> change_credential_wechat(credential_wechat)
      %Ecto.Changeset{data: %CredentialWechat{}}

  """
  def change_credential_wechat(%CredentialWechat{} = credential_wechat, attrs \\ %{}) do
    CredentialWechat.changeset(credential_wechat, attrs)
  end
end
