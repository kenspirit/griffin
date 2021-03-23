defimpl Phoenix.HTML.Safe, for: Map do
  def to_iodata(data) do
    Jason.encode!(data)
  end
end
