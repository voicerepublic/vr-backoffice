module ApplicationHelper

  def vrmedia_url(talk, suffix='-clean.mp3', local=false)
    url = "//#{request.host_with_port}/vrmedia/#{talk.id}#{suffix}"
    return url if local
    url.sub(':444', '').sub(':3001', ':3000')
  end

end
