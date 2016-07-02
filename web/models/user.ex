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

  def changeset(action, struct, params \\ %{})

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(:signup, struct, params) do
    struct
    |> cast(params, [:email, :password, :nickname])
    |> validate_required([:email, :password, :nickname], message: "不能为空")
    |> validate_format(:email, ~r/@/, message: "请输入正确的邮箱地址")
    |> unique_constraint(:email, message: "邮箱已被注册啦！")
    |> validate_length(:password, min: 6, max: 128)
    |> validate_length(:nickname, min: 1, max: 18)
    |> validate_exclusion(:nickname, ~w(admin, superadmin), message: "不允许注册的用户名")
    |> unique_constraint(:nickname, message: "昵称已被注册啦！")
  end

  def changeset(:signin, struct, params) do
    struct
    |> cast(params, [:email, :password])
    |> validate_required([:email, :password], message: "不能为空")
    |> validate_format(:email, ~r/@/, message: "请输入正确的邮箱地址")
    |> validate_length(:password, min: 6, max: 128)
  end

  @doc """
  验证用户邮箱是否存在
  """
  def validate_email(changeset) do
    if is_nil(changeset.changes.email) do
      changeset
      |> add_error(:email, "用户不存在")
    else
      changeset
    end
  end

  def validate_password(changeset) do
    changeset
  end

  def put_password_hash(changeset) do
    password_hash = changeset.changes.password
    |> Comeonin.Bcrypt.hashpwsalt

    changeset
    |> put_change(:password_hash, password_hash)
  end

  def check_password(password, password_hash) do
    password
    |> Comeonin.Bcrypt.checkpw(password_hash)
  end
end
