defmodule PhoenixChina.UserContext do
  import Ecto.{Query, Changeset}, warn: false
  alias PhoenixChina.Repo

  alias PhoenixChina.Models.User

  def list do
    Repo.all(User)
  end

  def get(id) do
    Repo.get(User, id)
  end

  def get!(id) do
    Repo.get!(User, id)
  end

  def get_by(:email, email) do
    case Repo.get_by(User, email: email) do
      nil -> {:error, nil}
      user -> {:ok, user}
    end
  end

  def create(attrs \\ %{}) do
    :create
    |> change_user(attrs)
    |> Repo.insert()
  end

  def update(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def update(token, %{"password" => _password} = attrs) when is_binary(token) do
    changeset = change_password_reset(%User{}, attrs)

    # token 12小时后过期
    with {:ok, user_id} <- validate_token(token),
      true <- changeset.valid? do
        changeset = %{changeset | data: get!(user_id)}
        Repo.update(changeset)
      else
        {:error, :invalid} -> {:error, :invalid}
        {:error, :expired} -> {:error, :expired}
        false ->
          {:ok, user_id} = validate_token(token)
          changeset = %{changeset | data: get!(user_id), action: :update}
          {:error, changeset}
      end
  end

  def delete(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(:create, attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
  end

  def change_password_reset(%User{} = user, attrs \\ %{}) do
    user
    |> User.changeset_password_reset(attrs)
  end

  def checkpw(%User{} = user, password) do
    Comeonin.Bcrypt.checkpw(password, user.password_hash)
  end

  def generate_token(%User{} = user, signed_at \\ System.system_time(:seconds)) do
    Phoenix.Token.sign(PhoenixChina.Web.Endpoint, "phoenix_china", user.id, signed_at: signed_at)
  end

  def validate_token(token) do
    Phoenix.Token.verify(PhoenixChina.Web.Endpoint, "phoenix_china", token, max_age: 43200)
  end
end