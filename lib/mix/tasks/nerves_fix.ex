defmodule Mix.Tasks.NervesFix do
  @moduledoc """
  Creates a symlink from deps/nerves_system_br to deps/clutch_nerves_system_br.

  This is needed because Nerves is hardcoded to look for the nerves_system_br package
  but our project uses clutch_nerves_system_br instead.
  """
  use Mix.Task

  @shortdoc "Creates a symlink for nerves_system_br"
  def run(_args) do
    # Make sure deps directory exists
    File.mkdir_p!("deps")
    
    # Check if clutch_nerves_system_br exists
    clutch_path = Path.expand("deps/clutch_nerves_system_br")
    target_path = Path.expand("deps/nerves_system_br")
    
    cond do
      File.exists?(clutch_path) && !File.exists?(target_path) ->
        File.ln_s(clutch_path, target_path)
        Mix.shell().info("Created symlink from deps/nerves_system_br to deps/clutch_nerves_system_br")
        
      File.exists?(clutch_path) && File.exists?(target_path) ->
        Mix.shell().info("Both deps/nerves_system_br and deps/clutch_nerves_system_br exist. No symlink needed.")
        
      !File.exists?(clutch_path) ->
        Mix.shell().error("deps/clutch_nerves_system_br does not exist. Run mix deps.get first.")
        exit({:shutdown, 1})
    end
  end
end 