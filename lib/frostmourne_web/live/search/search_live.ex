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
      ~S"[\w]+(-[\w]+)*){1}\.{1}(?<tld>[a-zA-Z]{2,6})?$|([\w]+(-[\w]+)*){1}$){1}"
    {:ok, domain_pattern} = Regex.compile(domain_regex)

    case Regex.named_captures(domain_pattern, query) do
      %{"domain_name" => domain, "tld" => ""} ->
        search_by(domain)

      %{"domain_name" => domain, "tld" => tld} ->
        search_by(domain, tld)

      _ -> []
    end
  end

  defp search_by(domain) do

    fuzzy_search = DomainRegister.get_domains_like(domain <> "%")
    results = search_by(domain, get_tlds())

    fuzzy_merge_occupied = MapSet.new(fuzzy_search) |> MapSet.put(results.occupied) |> MapSet.to_list()
    %{results | occupied: fuzzy_merge_occupied}

  end

  defp search_by(domain, tld) when is_list(tld) == false do
    case get_tlds(tld) do
      [] ->
        []
      tlds -> search_by(domain, tlds)
    end
  end

  defp search_by(domain, tlds) when is_list(tlds) == true do
    tld_ids = Enum.map tlds, & &1.id
    domain_combinations = Enum.map tlds, & Map.put(&1, :domain_name, domain)
    occupied_domains = DomainRegister.get_domain_by_name_and_tlds(domain, tld_ids)
    available_domains =
      MapSet.difference(MapSet.new(domain_combinations),
                        MapSet.new(occupied_domains))
      |> MapSet.to_list()
    %{available: available_domains, occupied: occupied_domains}
  end

  # TODO: Create function that fetches tlds from ETS instead.
  defp get_tlds() do
    DomainRegister.get_tlds()
  end

  # Hack: Some code smell
  defp get_tlds(name) do
    needle = name <> "%"
    DomainRegister.get_tlds_like(needle)
  end
end
