defmodule Liquidizer.Resizer do
    require Logger

    @doc """
    Crops image first and resize it after with specified arguments.
    If cached transformed image exists - will return it.
    If cached original image from specified url exists - will use it
    """
    def cropAndResize(url, h, w, cropY, cropX, cropH, cropW) do
        uri = URI.parse(url);
        localPath = Path.rootname(uri.path)
        path_to_dir = Path.join(["\\tmp\\", uri.host, localPath])
        basename = Path.basename(localPath)
        transformed_name = "#{basename}_h#{h}_w#{w}_cY#{cropY}_cX#{cropX}_cH#{cropH}_cW#{cropW}}" 
        path_to_file = Path.join([path_to_dir, transformed_name <> Path.extname(uri.path)])
        path_to_original = Path.join([path_to_dir, "original" <> Path.extname(uri.path)])

        Logger.debug("Checking file #{path_to_file} for exists")

        unless File.exists?(path_to_file) do
            Logger.debug("Not found transformed file, checking original file")

            check_and_download_file(path_to_original, url, path_to_dir)
            # I don't find any -output parametres for mogrify =(
                 
            File.copy!(path_to_original, path_to_file)
            Logger.debug("Original file copied.")
            Logger.debug("Start transforming 'Croping'")
            System.cmd("mogrify", ["-crop", "#{cropW}x#{cropH}+#{cropX}+#{cropY}", "#{path_to_file}"])
            Logger.debug("Start transforming 'Resizing'")
            System.cmd("mogrify", ["-resize", "#{w}x#{h}", "#{path_to_file}"])
            Logger.debug("Transformations done")
        end

        {:ok, image_file} = File.open(path_to_file, [:read])
        image_data = IO.binread(image_file, :all)

        # Mime type is hardcoded. Yep. Not good.
        %{mime_type: "jpeg", bindata: image_data}
    end

    def resize(url, h, w) do
        uri = URI.parse(url);
        localPath = Path.rootname(uri.path)
        path_to_dir = Path.join(["\\tmp\\", uri.host, localPath])
        basename = Path.basename(localPath)
        transformed_name = "#{basename}_h#{h}_w#{w}" 
        path_to_file = Path.join([path_to_dir, transformed_name <> Path.extname(uri.path)])
        path_to_original = Path.join([path_to_dir, "original" <> Path.extname(uri.path)])

        Logger.debug("Checking file #{path_to_file} for exists")

        unless File.exists?(path_to_file) do
            Logger.debug("Not found transformed file, checking original file")
            check_and_download_file(path_to_original, url, path_to_dir)
            # I don't find any -output parametres for mogrify =(
            File.copy!(path_to_original, path_to_file)
            Logger.debug("Original file copied.")
            Logger.debug("Start transforming 'Resizing'")
            System.cmd("mogrify", ["-resize", "#{w}x#{h}", "#{path_to_file}"])
            Logger.debug("Transformations done")
        end

        {:ok, image_file} = File.open(path_to_file, [:read])
        image_data = IO.binread(image_file, :all)

        # Mime type is hardcoded. Yep. Not good.
        %{mime_type: "jpeg", bindata: image_data}
    end

    defp check_and_download_file(path_to_original, url, path_to_dir) do
        unless File.exists?(path_to_original) do
            Logger.debug("Not found original file. downloading...")
            result = HTTPoison.get!(url)
            body = result.body
            File.mkdir_p(path_to_dir);
            Logger.debug("Directory tree created. Writing file")
            File.write!(path_to_original, body)
            Logger.debug("Done.")
        end
    end

end