defmodule Lexer do
  @moduledoc """
  Tokenizes C++ source code into lexical categories using regex patterns.

  Token types:
  - :comment       ^\/\/.*
  - :preprocessor  ^#\w+
  - :string        ^"[^"]*"
  - :char          ^'[^']*'
  - :float         ^\d+\.\d+
  - :integer       ^\d+
  - :operator      ^[+\-*\/<>=!&|;,{}[\].:]
  - :class_name    ^[A-Z]\w*
  - :identifier    ^[a-z_]\w*
  - :reserved_word matched from :identifier against keyword list
  - :whitespace    ^\s+
  """

  @reserved ~w(int float double char bool void return if else while for do
               break continue class struct true false nullptr new delete
               public private protected const static namespace using
               switch case default)

  @patterns [
    {:comment,      ~r/^\/\/.*/},
    {:preprocessor, ~r/^#\w+/},
    {:string,       ~r/^"[^"]*"/},
    {:char,         ~r/^'[^']*'/},
    {:float,        ~r/^\d+\.\d+/},
    {:integer,      ~r/^\d+/},
    {:operator,     ~r/^[+\-*\/<>=!&|;,{}[\].:]/ },
    {:class_name,   ~r/^[A-Z]\w*/},
    {:identifier,   ~r/^[a-z_]\w*/},
    {:whitespace,   ~r/^\s+/}
  ]

  @doc "Tokenizes a C++ source string into a list of {type, value} tuples."
  def tokenize(source), do: tokenize(source, [])

  defp tokenize("", acc), do: Enum.reverse(acc)

  defp tokenize(source, acc) do
    case next_token(source) do
      {type, value, rest} ->
        type = if type == :identifier and value in @reserved, do: :reserved_word, else: type
        tokenize(rest, [{type, value} | acc])

      nil ->
        {char, rest} = String.split_at(source, 1)
        tokenize(rest, [{:unknown, char} | acc])
    end
  end

  defp next_token(source) do
    Enum.find_value(@patterns, fn {type, regex} ->
      case Regex.run(regex, source, return: :index) do
        [{0, len}] ->
          {value, rest} = String.split_at(source, len)
          {type, value, rest}
        _ -> nil
      end
    end)
  end
end

defmodule HTMLOutput do
  @moduledoc "Renders a token list as a highlighted HTML page with a legend."

  @legend [:reserved_word, :identifier, :class_name, :float, :integer,
           :string, :char, :operator, :comment, :preprocessor]

  @labels %{
    reserved_word: "keyword",
    identifier:    "identifier",
    class_name:    "class / type",
    float:         "float",
    integer:       "integer",
    string:        "string",
    char:          "char",
    operator:      "operator",
    comment:       "comment",
    preprocessor:  "preprocessor"
  }

  @doc "Returns the full HTML string for the highlighted file."
  def render(tokens, title) do
    """
    <!DOCTYPE html>
    <html lang="en">
    <head>
    <meta charset="UTF-8">
    <title>#{title}</title>
    <style>
      body           { background: #1e1e1e; color: #d4d4d4; font-family: monospace; font-size: 14px; padding: 24px; }
      pre            { line-height: 1.6; }
      .reserved_word { color: #569cd6; }
      .identifier    { color: #9cdcfe; }
      .class_name    { color: #4ec9b0; }
      .float         { color: #b5cea8; }
      .integer       { color: #b5cea8; }
      .string        { color: #ce9178; }
      .char          { color: #ce9178; }
      .operator      { color: #d4d4d4; }
      .comment        { color: #6a9955; }
      .preprocessor  { color: #c586c0; }
      .unknown       { color: #f44747; }
      .legend        { margin-top: 24px; border-top: 1px solid #444; padding-top: 12px; font-size: 12px; color: #aaa; }
      .legend span   { margin-right: 16px; }
      .dot           { display: inline-block; width: 8px; height: 8px; border-radius: 50%; margin-right: 4px; }
    </style>
    </head>
    <body>
    <pre>#{code_html(tokens)}</pre>
    <div class="legend">#{legend_html()}</div>
    </body>
    </html>
    """
  end

  defp code_html(tokens) do
    tokens
    |> Enum.map(fn
      {:whitespace, value} -> html_escape(value)
      {type, value}        -> ~s(<span class="#{type}">#{html_escape(value)}</span>)
    end)
    |> Enum.join()
  end

  defp legend_html do
    @legend
    |> Enum.map(fn type ->
      ~s(<span><span class="dot #{type}" style="background:currentColor"></span>#{@labels[type]}</span>)
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

:timer.tc(fn ->
  System.argv()
  |> Enum.map(fn input_file ->
    Task.async(fn ->
      tokens = input_file |> File.read!() |> Lexer.tokenize()
      html   = HTMLOutput.render(tokens, Path.basename(input_file))
      output = Path.rootname(input_file) <> "_highlighted.html"
      File.write!(output, html)
      IO.puts("Written: #{output}")
    end)
  end)
  |> Enum.map(&Task.await(&1, :infinity))
end)
|> then(fn {micros, _} -> IO.puts("Time: #{micros / 1_000_000} seconds") end)

