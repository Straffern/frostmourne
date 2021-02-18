defmodule FrostmourneWeb.SearchLive do
  use FrostmourneWeb, :live_view
  require Logger

  alias Frostmourne.DomainRegister

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", results: %{})}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    {:noreply, assign(socket, results: search(query), query: query)}
  end

  defp search(query) do

    # Improve pattern: https://medium.com/@vaghasiyaharryk/how-to-validate-a-domain-name-using-regular-expression-9ab484a1b430
    domain_regex =
      ~S"(?:(http[s]?:\/\/(www\.)?)|(www\.){1})?(?<domain>(?<domain_name>" <>
      ~S"[\w]+(-[\w]+)*){1}\.{1}(?<tld>[a-zA-Z]{2,63})?$|([\w]+(-[\w]+)*){1}$){1}"
    {:ok, domain_pattern} = Regex.compile(domain_regex)

    case Regex.named_captures(domain_pattern, query) do
      %{"domain_name" => domain, "tld" => ""} ->
        search_given(domain)

      %{"domain_name" => domain, "tld" => tld} ->
        search_given(domain, tld)

      %{error: error} ->
        Logger.log(:error, "Failed to retrieve search results", error)
        []
      _ -> []
    end
  end

  defp search_given(domain) do
    case get_tlds() do
      {:ok, tlds} ->
        search_given(domain, tlds)
      {:error, _err} -> {:error, :fetch_tlds_error}
    end
  end

  defp search_given(domain, tld) when is_list(tld) == false do
    case get_tlds() do
      {:ok, tlds} ->
        # TODO: filter fetched domains, such that list only contains elements that have argument: tld, as a substring.
        :NotImplementedYet
      {:error, _err} -> {:error, :fetch_tlds_error}
    end
  end

  defp search_given(domain, tlds) when is_list(tlds) do
    domain_combinations = Enum.map(tlds, fn %{tld: tld} -> "#{domain}.#{tld}" end)

    case DomainRegister.get_registered_domains(domain) do
      {:ok, registered_domains} ->
        transformed_reg_domains = Enum.map(registered_domains, fn %{domain_name: domain, tld: tld} -> "#{domain}.#{tld}" end)
        available_domains = MapSet.difference(MapSet.new(domain_combinations), MapSet.new(transformed_reg_domains)) |> MapSet.to_list()
        %{available: available_domains, occupied: transformed_reg_domains}
      {:error, _err} -> {:error, :fetch_active_records_error}
    end
  end


  # TODO: Create function that fetches tlds from ETS instead.
  defp get_tlds() do
    DomainRegister.get_tlds()
  end
end
