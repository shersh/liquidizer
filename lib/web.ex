defmodule Liquidizer.Web do
    use Plug.Router
    require Logger

    plug Plug.Logger
    plug :match
    plug :dispatch

    def init(options) do
        options
    end

    def start_link do
        {:ok, _} = Plug.Adapters.Cowboy.http Liquidizer.Web, [], port: 4000
    end

    get "/resize" do
        conn = fetch_query_params(conn)
        Logger.debug("Called resize with params #{inspect(conn.params)}")
        
        case conn.params do
            %{ "url" => url, "h" => h, "w" => w, "cropY" => cropY, "cropX" => cropX, "cropH" => cropH, "cropW" => cropW } ->
                %{mime_type: mime, bindata: data} = Liquidizer.Resizer.cropAndResize(url, h, w, cropY, cropX, cropH, cropW)
                conn = conn 
                |> put_resp_content_type("image/#{mime}")
                |> send_resp(200,  data)

            %{ "url" => url, "h" => h, "w" => w} ->
                %{mime_type: mime, bindata: data} = Liquidizer.Resizer.resize(url, h, w)
                conn = conn 
                |> put_resp_content_type("image/#{mime}")
                |> send_resp(200,  data)
            _ ->
                Logger.error("Do not match any method for " <> inspect(conn.params))
                conn = conn 
                |> send_resp(400, "Bad bad bad request")
                
        end

        conn |> halt
    end

    match _ do 
        conn 
        |> send_resp(404, "Nothing to do here")
        |> halt
    end

end