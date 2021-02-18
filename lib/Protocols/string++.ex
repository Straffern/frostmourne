defimpl String.Chars, for: Map do
  def to_string(%{"domain_name" => domain, "tld" => tld}) do "#{domain}.#{tld}" end
  def to_string(_) do raise Protocol.UndefinedError end
end
