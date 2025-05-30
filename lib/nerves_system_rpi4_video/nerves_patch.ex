defmodule NervesSystemRpi4Video.NervesPatch do
  @moduledoc """
  Monkey patch for Nerves to use clutch_nerves_system_br instead of nerves_system_br.
  """

  def apply_patch do
    # Only apply the patch if we need to (clutch_nerves_system_br is in use)
    if Enum.any?(Nerves.Env.packages(), fn pkg -> pkg.app == :clutch_nerves_system_br end) do
      # Store the original package lookup function
      original_package_fn = Function.capture(Nerves.Env, :package, 1)
      
      # Define our override function
      custom_package_fn = fn
        :nerves_system_br ->
          # If asking for nerves_system_br, return clutch_nerves_system_br instead
          Enum.find(Nerves.Env.packages(), &(&1.app == :clutch_nerves_system_br))
        arg ->
          # For all other packages, use the original function
          original_package_fn.(arg)
      end
      
      # Apply the monkey patch if needed
      if Code.ensure_loaded?(:meck) do
        try do
          # Try unsticking first if needed
          try_unstick_module(Nerves.Env)
          
          :meck.new(Nerves.Env, [:passthrough])
          :meck.expect(Nerves.Env, :package, custom_package_fn)
          IO.puts("Applied NervesSystemRpi4Video.NervesPatch to use clutch_nerves_system_br")
          :ok
        rescue
          e -> 
            IO.puts("Failed to apply patch with meck: #{inspect(e)}")
            IO.puts("Falling back to symlink approach")
            create_symlink()
            :ok
        end
      else
        IO.puts("Meck not available, using symlink approach")
        create_symlink()
        :ok
      end
    end
  end
  
  # Helper function to create the symlink
  defp create_symlink do
    # Make sure deps directory exists
    File.mkdir_p!("deps")
    
    # Check if clutch_nerves_system_br exists
    clutch_path = Path.expand("deps/clutch_nerves_system_br")
    target_path = Path.expand("deps/nerves_system_br")
    
    if File.exists?(clutch_path) and not File.exists?(target_path) do
      File.ln_s(clutch_path, target_path)
      IO.puts("Created symlink from deps/nerves_system_br to deps/clutch_nerves_system_br")
    end
  end
  
  # Helper to unstick modules if needed
  defp try_unstick_module(module) do
    try do
      Code.compiler_options(ignore_module_conflict: true)
      :code.purge(module)
      :code.delete(module)
    rescue
      _ -> :ok
    after
      Code.compiler_options(ignore_module_conflict: false)
    end
  end
end 