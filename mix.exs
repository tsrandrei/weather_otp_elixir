defmodule MetexOtp.MixProject do
  use Mix.Project

  def project do
    [
      app: :metex_otp,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.7.0"},
      {:json, "~> 1.3.0"}
    ]
  end
end
