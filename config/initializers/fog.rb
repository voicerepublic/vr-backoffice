fog_config = Settings.fog ? Settings.fog.storage.to_hash : {}
Storage = Fog::Storage.new(fog_config)

# when using local storage provider, fake expiring urls with public
# urls
class Fog::Storage::Local::File
  def url(args)
    public_url
  end
end
