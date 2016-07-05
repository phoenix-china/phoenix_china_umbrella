defmodule PhoenixChina.User do
  use PhoenixChina.Web, :model

  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :avatar, :string
    field :nickname, :string

    field :password, :string, virtual: true
    field :old_password, :string, virtual: true
    field :password_confirm, :string, virtual: true

    timestamps()
  end

  def changeset(action, struct, params \\ %{})

  def changeset(:edit, struct, params) do
    struct
    |> cast(params, [:avatar, :nickname])
    |> validate_required([:avatar, :nickname], message: "不能为空")
    |> validate_length(:nickname, min: 1, max: 18)
    |> validate_exclusion(:nickname, ~w(admin, superadmin), message: "不允许使用的用户名")
    |> unique_constraint(:nickname, message: "昵称已被注册啦！")
  end

  def changeset(:signup, struct, params) do
    struct
    |> cast(params, [:email, :password, :nickname])
    |> validate_required([:email, :password, :nickname], message: "不能为空")
    |> validate_format(:email, ~r/@/, message: "请输入正确的邮箱地址")
    |> unique_constraint(:email, message: "邮箱已被注册啦！")
    |> validate_length(:password, min: 6, max: 128)
    |> validate_length(:nickname, min: 1, max: 18)
    |> validate_exclusion(:nickname, ~w(admin, superadmin), message: "不允许使用的用户名")
    |> unique_constraint(:nickname, message: "昵称已被注册啦！")
  end

  def changeset(:signin, struct, params) do
    struct
    |> cast(params, [:email, :password])
    |> validate_required([:email, :password], message: "不能为空")
    |> validate_format(:email, ~r/@/, message: "请输入正确的邮箱地址")
    |> validate_length(:password, min: 6, max: 128)
  end

  def changeset(:account, struct, params) do
    struct
    |> cast(params, [:old_password, :password, :password_confirm])
    |> validate_required([:old_password, :password, :password_confirm], message: "不能为空")
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

  def check_password?(password, password_hash) do
    check_password(password, password_hash)
  end

  def validate_password(changeset, field) do
    password = get_field(changeset, field)
    password_hash = get_field(changeset, :password_hash)

    case check_password?(password, password_hash) do
      false ->
        changeset
        |> add_error(field, "密码错误")
      true ->
        changeset
    end
  end

  def validate_equal_to(changeset, field, to_field) do
    data1 = get_field(changeset, field)
    data2 = get_field(changeset, to_field)

    case data1 == data2 do
      false ->
        changeset
        |> add_error(field, "两次输入不一致")
      true ->
        changeset
    end
  end

  def new_list do
    query = from __MODULE__, order_by: [desc: :inserted_at], limit: 10
    query |> PhoenixChina.Repo.all
  end
end
