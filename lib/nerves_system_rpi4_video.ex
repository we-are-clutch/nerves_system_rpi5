defmodule NervesSystemRpi4Video do
  @moduledoc """
  Documentation for `NervesSystemRpi4Video`.
  """

  @doc """
  Monkey patch Nerves to use clutch_nerves_system_br.
  """
  def patch_nerves do
    # Store original package function from Nerves.Env
    original_package = Function.capture(Nerves.Env, :package, 1)
    
    # Define our custom package lookup function
    custom_package = fn
      :nerves_system_br ->
        # Find clutch_nerves_system_br if nerves_system_br is requested
        clutch_package = Enum.find(Nerves.Env.packages(), &(&1.app == :clutch_nerves_system_br))
        
        if clutch_package do
          # Return clutch_nerves_system_br with :path set
          Map.put(clutch_package, :path, Path.join(File.cwd!(), "deps/clutch_nerves_system_br"))
        else
          # Fallback to original function
          original_package.(:nerves_system_br)
        end
      
      other_package ->
        # Use original function for all other packages
        original_package.(other_package)
    end
    
    # Apply the monkey patch using :meck only if available
    try do
      # Check if meck is available
      if Code.ensure_loaded?(:meck) do
        # Try unsticking first if needed
        try_unstick_module(Nerves.Env)
        
        :meck.new(Nerves.Env, [:passthrough, :unstick])
        :meck.expect(Nerves.Env, :package, custom_package)
        IO.puts("Applied NervesSystemRpi4Video patch to use clutch_nerves_system_br")
        :ok
      else
        IO.puts("Warning: :meck not available - trying direct method instead")
        # Use the symlink approach instead as fallback
        create_symlink()
        :ok
      end
    rescue
      e -> 
        IO.puts("Failed to apply Nerves patch: #{inspect(e)}")
        IO.puts("Falling back to symlink approach")
        create_symlink()
        :ok
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