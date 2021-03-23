defimpl Phoenix.HTML.Safe, for: Griffin.Exchange.ExchangeLocation do
  def to_iodata(data) do
    data.name
  end
end
