defmodule PhoenixChina.Qiniu do
  @config Application.get_env(:qiniu, Qiniu)

  @policy Qiniu.PutPolicy.build(@config[:resource])

  def upload(file) do
    filename = generate_filename(file)
    response = Qiniu.Uploader.upload @policy, file.path, key: filename

    case response.body |> Poison.Parser.parse! do
      %{"hash" => hash, "key" => key} ->
        {:ok, %{
          hash: hash,
          key: key,
          url: "#{@config[:domain]}/#{filename}"
        }}
      errors ->
        {:error, errors}
    end
  end

  defp generate_filename(file) do
    filetype = file.filename |> String.split(".") |> List.last
    str = "#{file.content_type}#{file.path}#{file.filename}"

    filename = :crypto.hash(:md5, str)
    |> Base.encode16(case: :lower)

    "#{filename}.#{filetype}"
  end
end
