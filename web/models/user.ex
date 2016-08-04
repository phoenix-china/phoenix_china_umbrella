defmodule PhoenixChina.User do
  use PhoenixChina.Web, :model

  alias PhoenixChina.Repo

  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :avatar, :string
    field :nickname, :string
    field :bio, :string
    field :collect_count, :integer, default: 0
    field :follower_count, :integer, default: 0
    field :followed_count, :integer, default: 0

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :old_password, :string, virtual: true
    field :token, :string, virtual: true
    field :luotest_response, :string, virtual: true

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
    |> cast(params, [:email, :password, :nickname, :luotest_response])
    |> validate_required([:email, :password, :nickname], message: "不能为空")
    |> validate_format(:email, ~r/@/, message: "请输入正确的邮箱地址")
    |> unique_constraint(:email, message: "邮箱已被注册啦！")
    |> validate_length(:password, min: 6, max: 128)
    |> validate_length(:nickname, min: 1, max: 18)
    |> validate_exclusion(:nickname, ~w(admin, superadmin), message: "不允许使用的用户名")
    |> unique_constraint(:nickname, message: "昵称已被注册啦！")
    |> put_password_hash
    |> put_avatar
  end

  def changeset(:signin, struct, params) do
    struct
    |> cast(params, [:email, :password, :luotest_response])
    |> validate_required([:email, :password], message: "不能为空")
    |> validate_format(:email, ~r/@/, message: "请输入正确的邮箱地址")
    |> validate_length(:password, min: 6, max: 128)
    |> validate_email
    |> validate_password(:password)
  end

  def changeset(:account, struct, params) do
    struct
    |> cast(params, [:old_password, :password, :password_confirmation])
    |> validate_required([:old_password, :password, :password_confirmation], message: "不能为空")
    |> validate_length(:password, min: 6, max: 128)
    |> validate_confirmation(:password, message: "两次密码输入不一致")
    |> validate_password(:old_password)
    |> put_password_hash
  end

  def changeset(:password_forget, struct, params) do
    struct
    |> cast(params, [:email])
    |> validate_required([:email], message: "不能为空")
    |> validate_format(:email, ~r/@/, message: "请输入正确的邮箱地址")
    |> validate_email
  end

  def changeset(:password_reset, struct, params) do
    struct
    |> cast(params, [:token, :password, :password_confirmation])
    |> validate_required([:token, :password, :password_confirmation], message: "不能为空")
    |> validate_length(:password, min: 6, max: 128)
    |> validate_confirmation(:password, message: "两次密码输入不一致")
    |> validate_token(:token, "user_id", 60 * 60 * 24)
    |> put_password_hash
  end

  def changeset(:profile, struct, params) do
    struct
    |> cast(params, [:nickname, :bio], [:avatar])
    |> validate_required([:nickname], message: "不能为空")
    |> validate_length(:nickname, min: 1, max: 18)
    |> validate_exclusion(:nickname, ~w(admin, superadmin), message: "不允许使用的用户名")
    |> unique_constraint(:nickname, message: "昵称已被注册啦，请更换别的昵称试试")
    |> validate_length(:bio, max: 140)
  end

  # defp validate_luotest_response(changeset) do
  #   case changeset.changes do
  #     %{"luotest_response": luotest_response} ->
  #       case PhoenixChina.Luosimao.captcha_verify?(luotest_response) do
  #         true ->
  #           changeset
  #         false ->
  #           changeset
  #           |> Ecto.Changeset.add_error(:luotest_response, "人机识别验证失败")
  #       end
  #     _ ->
  #     changeset
  #   end
  # end

  defp validate_email(changeset) do
    case changeset.changes do
      %{"email": email} ->
        user = __MODULE__ |> Repo.get_by(email: email)

        case !!user do
          true ->
            changeset
          false ->
            changeset
            |> Ecto.Changeset.add_error(:email, "用户不存在")
        end
      _ ->
        changeset
    end
  end

  def validate_password(changeset, field \\ :password) do
    user = case changeset.changes do
      %{"email": email} ->
        __MODULE__ |> Repo.get_by(email: email)
      _ ->
        changeset.data
    end

    case user do
      %{"password_hash": password_hash} ->
        changeset |> validate_change(field, fn field, password ->
          if password |> String.length <= 0 do
            []
          else
            case check_password?(password, password_hash) do
              true ->
                []
              false ->
                case field do
                  :old_password ->
                    [old_password: "密码错误"]
                  _ ->
                    [password: "密码错误"]
                end
            end
          end
        end)
      _ ->
        changeset
    end
  end

  def validate_token(changeset, field, token_name, max_age) do
    token = get_field(changeset, field)
    case Phoenix.Token.verify(PhoenixChina.Endpoint, token_name, token, max_age: max_age) do
      {:ok, user_id} ->
        user = __MODULE__ |> Repo.get!(user_id)
        changeset
        |> Ecto.Changeset.put_change(:user, user)
      {:error, :invalid} ->
        changeset
        |> Ecto.Changeset.add_error(field, "token不正确，请重新申请重置密码！")
      {:error, :expired} ->
        changeset
        |> Ecto.Changeset.add_error(field, "token已过期，请重新申请重置密码！")
    end
  end

  def put_password_hash(changeset) do
    case changeset.changes do
      %{:password => password} ->
        changeset
        |> put_change(:password_hash, Comeonin.Bcrypt.hashpwsalt(password))
      _ ->
        changeset
    end
  end

  def check_password?(password, password_hash) do
    password
    |> Comeonin.Bcrypt.checkpw(password_hash)
  end

  def put_avatar(%Ecto.Changeset{valid?: true} = changeset) do
    email = get_field(changeset, :email)
    |> String.trim
    |> String.downcase

    email_md5 = :crypto.hash(:md5, email)
    |> Base.encode16(case: :lower)

    avatar = "https://gravatar.tycdn.net/avatar/#{email_md5}?d=wavatar&s=#200"

    changeset |> put_change(:avatar, avatar)
  end

  def new_list do
    __MODULE__
    |> order_by(desc: :inserted_at)
    |> limit(10)
    |> Repo.all
  end

  def generate_token(user, token_name \\ "user_id") do
    Phoenix.Token.sign(PhoenixChina.Endpoint, token_name, user.id)
  end

  def inc(module \\ %__MODULE__{}, field)

  def inc(%__MODULE__{:id => user_id}, :collect_count) do
    __MODULE__
    |> where(id: ^user_id)
    |> update(inc: [collect_count: 1])
    |> Repo.update_all([])
  end

  def inc(%__MODULE__{:id => user_id}, :follower_count) do
    __MODULE__
    |> where(id: ^user_id)
    |> update(inc: [follower_count: 1])
    |> Repo.update_all([])
  end

  def inc(%__MODULE__{:id => user_id}, :followed_count) do
    __MODULE__
    |> where(id: ^user_id)
    |> update(inc: [followed_count: 1])
    |> Repo.update_all([])
  end

  def dsc(module \\ %__MODULE__{}, field)

  def dsc(%__MODULE__{:id => user_id}, :collect_count) do
    __MODULE__
    |> where(id: ^user_id)
    |> update(inc: [collect_count: -1])
    |> Repo.update_all([])
  end

  def dsc(%__MODULE__{:id => user_id}, :follower_count) do
    __MODULE__
    |> where(id: ^user_id)
    |> update(inc: [follower_count: -1])
    |> Repo.update_all([])
  end

  def dsc(%__MODULE__{:id => user_id}, :followed_count) do
    __MODULE__
    |> where(id: ^user_id)
    |> update(inc: [followed_count: -1])
    |> Repo.update_all([])
  end
end
