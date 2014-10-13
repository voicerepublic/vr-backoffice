Storage = Fog::Storage.new(Settings.fog.storage.to_hash)

# when using local storage provider, fake expiring urls with public
# urls
class Fog::Storage::Local::File
  def url(args)
    public_url
  end
end
