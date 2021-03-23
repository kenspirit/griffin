defimpl Phoenix.HTML.Safe, for: Griffin.Treasure.Gem do
  def to_iodata(data) do
    "#{data.name} (#{data.code})"
  end
end
