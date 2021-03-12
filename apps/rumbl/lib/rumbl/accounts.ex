defmodule Rumbl.Accounts do
  import Ecto.Query

  @moduledoc """
  A thin layer for Ecto.Repo specifically for accessing accounts
  """
  alias Rumbl.Repo
  alias Rumbl.Accounts.User

  @doc """
  Return a user given an id
  """
  @spec get_user(integer()) :: %User{}
  def get_user(id) do
    Repo.get(User, id)
  end

  @spec get_user!(integer()) :: %User{}
  def get_user!(id) do
    Repo.get!(User, id)
  end

  @spec get_user!(map()) :: %User{}
  def get_user_by(params) do
    Repo.get_by(User, params)
  end

  @spec list_users() :: %User{}
  def list_users do
    Repo.all(User)
  end

  @spec change_user(%User{}) :: Ecto.Changeset
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @spec create_user(map()) :: Ecto.Changeset
  def create_user(user_params) do
    User.changeset(%User{}, user_params) |> Repo.insert()
  end

  @spec change_registration(%User{}, map()) :: Ecto.Changeset
  def change_registration(user, params) do
    User.registration_changeset(%User{} = user, params)
  end

  def list_users_with_ids(ids) do
    Repo.all(from(u in User, where: u.id in ^ids))
  end

  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def authenticate_by_username_and_pass(username, given_pass) do
    user = get_user_by(username: username)

    cond do
      user && Pbkdf2.verify_pass(given_pass, user.password_hash) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        Pbkdf2.no_user_verify()
        {:error, :not_found}
    end
  end
end
