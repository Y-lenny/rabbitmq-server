defmodule ListBindingsCommand do
    @behaviour Command

    @info_keys ~w(source_name source_kind destination_name destination_kind routing_key arguments)a

    def flags() do
        [:param]
    end

    def usage() do
        "list_bindings [-p <vhost>] [<bindinginfoitem> ...]"
    end

    def usage_additional() do
        "<bindinginfoitem> must be a member of the list ["<>
        Enum.join(@info_keys, ", ") <>"]."
    end

    def run([], opts) do
        run(~w(source_name source_kind
               destination_name destination_kind
               routing_key arguments),
            opts)
    end
    def run([_|_] = args, %{node: node_name, timeout: timeout, param: vhost} = opts) do
        info_keys = Enum.map(args, &String.to_atom/1)
        InfoKeys.with_valid_info_keys(args, @info_keys,
            fn(info_keys) ->
                info(opts)
                node_name
                |> Helpers.parse_node
                |> RpcStream.receive_list_items(:rabbit_binding, :info_all,
                                                [vhost, info_keys],
                                                timeout,
                                                info_keys)
            end)
    end
    def run([_|_] = args, %{node: node_name, timeout: timeout} = opts) do
        run(args, Map.merge(default_opts, opts))
    end

    defp default_opts() do
        %{param: "/"}
    end

    defp info(%{quiet: true}), do: nil
    defp info(_), do: IO.puts "Listing bindings ..."

end