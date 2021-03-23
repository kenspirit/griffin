defmodule Lolth.Spider.CrawledResult do
  @moduledoc """
  Defines the structure of URL crawled result
  """

  defstruct url: nil, success: false, invalid: false, failed_reason: nil, next_urls: [], result: nil, params: %{}

  @type t :: %__MODULE__{
    url: String.t(),
    success: boolean(),
    invalid: boolean(),
    failed_reason: String.t(),
    next_urls: [String.t()],
    result: map(),
    params: map()
  }
end
