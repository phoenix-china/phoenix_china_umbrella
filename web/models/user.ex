defmodule PhoenixChina.User do
  use PhoenixChina.Web, :model

  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :avatar, :string
    field :nickname, :string

    field :password, :string, virtual: true

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}, :signup) do
    struct
    |> cast(params, [:email, :password, :nickname])
    |> validate_required([:email, :password, :nickname], message: "不能为空")
    |> validate_format(:email, ~r/@/, message: "请输入正确的邮箱地址")
    |> unique_constraint(:email, message: "邮箱已被注册啦！")
    |> validate_length(:password, min: 6, max: 128)
    |> validate_length(:nickname, min: 1, max: 18)
    |> unique_constraint(:nickname, message: "昵称已被注册啦！")
  end

  def changeset(struct, params \\ %{}, :signin) do
     struct
     |> cast(params, [:email, :password])
     |> validate_required([:email, :password], message: "不能为空")
     |> validate_format(:email, ~r/@/, message: "请输入正确的邮箱地址")
     |> validate_length(:password, min: 6, max: 128)
  end

  def put_password_hash(changeset) do
    password_hash = changeset.changes.password
    |> Comeonin.Bcrypt.hashpwsalt

    changeset
    |> put_change(:password_hash, password_hash)
  end

  def check_password(changeset, password) do
    password
    |> Comeonin.Bcrypt.checkpw(changeset.changes.password_hash)
  end
end
