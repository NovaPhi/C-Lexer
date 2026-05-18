defmodule Lexer do
  @moduledoc """
  Tokenizes C++ source code into lexical categories.
  Uses regex patterns matched left-to-right on the remaining input.
  Luis Jaime Arias
  May 14 2026
  """

  @reserved ~w(int float double char bool void return if else while for do
               break continue class struct true false nullptr new delete
               public private protected const static namespace using)

  @token_patterns [
    {:comment,      ~r/^\/\/.*/},
    {:preprocessor, ~r/^#\w+/},
    {:string,       ~r/^"[^"]*"/},
    {:integer,      ~r/^\d+/},
    {:operator,     ~r/^[+\-*\/<>=!&|;,{}[\]]/},
    {:identifier,   ~r/^[a-zA-Z_]\w*/},
    {:whitespace,   ~r/^\s+/}
  ]

  @doc """
  Tokenizes a C++ source string into a list of {type, value} tuples.
  """
  def tokenize(source), do: tokenize(source, [])

  defp tokenize("", acc), do: Enum.reverse(acc)

  defp tokenize(source, acc) do
    case match_token(source) do
      {type, value, rest} ->
        type = if type == :identifier and value in @reserved, do: :reserved_word, else: type
        tokenize(rest, [{type, value} | acc])

      nil ->
        {skipped, rest} = String.split_at(source, 1)
        tokenize(rest, [{:unknown, skipped} | acc])
    end
  end

  defp match_token(source) do
    Enum.find_value(@token_patterns, fn {type, regex} ->
      case Regex.run(regex, source, return: :index) do
        [{0, len}] ->
          {value, rest} = String.split_at(source, len)
          {type, value, rest}

        _ ->
          nil
      end
    end)
  end
end

defmodule HTMLOutput do
  @moduledoc """
  Renders a token list as an HTML page with color-coded syntax highlighting
  and a legend at the bottom.
  """

  @legend_types [:reserved_word, :identifier, :integer, :string, :operator, :comment, :preprocessor]

  @doc """
  Returns the highlight color for a given token type.
  """
  def color(:reserved_word), do: "#569cd6"
  def color(:identifier),    do: "#9cdcfe"
  def color(:integer),       do: "#b5cea8"
  def color(:string),        do: "#ce9178"
  def color(:operator),      do: "#d4d4d4"
  def color(:comment),       do: "#6a9955"
  def color(:preprocessor),  do: "#c586c0"
  def color(:whitespace),    do: nil
  def color(:unknown),       do: "#f44747"

  @doc """
  Returns the human-readable label for a given token type.
  """
  def label(:reserved_word), do: "keyword"
  def label(:identifier),    do: "identifier"
  def label(:integer),       do: "integer"
  def label(:string),        do: "string"
  def label(:operator),      do: "operator"
  def label(:comment),       do: "comment"
  def label(:preprocessor),  do: "preprocessor"
  def label(_),              do: nil

  @doc """
  Builds and returns the full HTML string for the highlighted file.
  """
  def render(tokens, title) do
    code_html = build_code_html(tokens)
    legend_html = build_legend_html()

    """
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <meta charset="UTF-8">
    <title>#{title}</title>
    <style>
      body {
        background: #1e1e1e;
        color: #d4d4d4;
        font-family: monospace;
        font-size: 14px;
        padding: 24px;
      }
      pre { line-height: 1.6; }
      .legend {
        margin-top: 24px;
        border-top: 1px solid #444;
        padding-top: 12px;
        font-size: 12px;
        color: #aaa;
      }
      .legend span { margin-right: 16px; }
      .dot {
        display: inline-block;
        width: 8px;
        height: 8px;
        border-radius: 50%;
        margin-right: 4px;
      }
    </style>
    </head>
    <body>
    <pre>#{code_html}</pre>
    <div class="legend">#{legend_html}</div>
    </body>
    </html>
    """
  end

  defp build_code_html(tokens) do
    tokens
    |> Enum.map(fn {type, value} ->
      escaped = html_escape(value)

      case color(type) do
        nil -> escaped
        c   -> ~s(<span style="color:#{c}">#{escaped}</span>)
      end
    end)
    |> Enum.join()
  end

  defp build_legend_html do
    @legend_types
    |> Enum.map(fn type ->
      ~s(<span><span class="dot" style="background:#{color(type)}"></span>#{label(type)}</span>)
    end)
    |> Enum.join()
  end

  defp html_escape(str) do
    str
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
  end
end

files = System.argv()

Enum.each(files, fn input_file ->
  source = File.read!(input_file)
  tokens = Lexer.tokenize(source)
  title  = Path.basename(input_file)
  html   = HTMLOutput.render(tokens, title)

  output = Path.rootname(input_file) <> "_highlighted.html"
  File.write!(output, html)
  IO.puts("Written: #{output}")
end)
