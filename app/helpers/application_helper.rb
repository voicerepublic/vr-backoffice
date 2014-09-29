module ApplicationHelper

  def vrmedia_url(talk, suffix='-clean.mp3')
    "//#{request.host_with_port}".
      sub(':444', '').
      sub(':3001', ':3000') +
      "/vrmedia/#{talk.id}#{suffix}"
  end

end
