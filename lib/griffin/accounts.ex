defmodule Griffin.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Griffin.Repo

  alias Griffin.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  def get_user(id), do: Repo.get(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.update_profile_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def user_existed?(loginid) do
    query = from u in User, where: u.loginid == ^loginid
    Repo.exists?(query)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> registration_changeset(user)
      %Ecto.Changeset{data: %User{}}

  """
  def registration_changeset(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs)
  end

  def login_changeset(%User{} = user, attrs \\ %{}) do
    User.login_changeset(user, attrs)
  end

  def authenticate_locally(loginid, token) do
    query = from u in User, where: u.loginid == ^loginid

    case Repo.one(query) do
      nil ->
        Argon2.no_user_verify()
        {:error, :invalid_credentials}
      user ->
        if Griffin.OTP.valid_totp?(token, user.totp_secret) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
    end
  end

  def is_admin_user(%User{} = user) do
    Enum.any?(user.roles, fn role -> role == "ADMIN" end)
  end

  def get_admin_user() do
    query = from u in User, where: "ADMIN" in u.roles
    Repo.one!(query)
  end
end
