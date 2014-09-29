class Vrmedia < Struct.new(:app, :opts)

  PATTERN = /^\/vrmedia\/(\d+)(.+)$/ # e.g. /vrmedia/1-pj.m4a

  def call(env)
    return app.call(env) unless env['REQUEST_METHOD'] == 'GET'
    return app.call(env) unless md = env['PATH_INFO'].match(PATTERN)

    location = env['REQUEST_URI'].sub(':444', '').sub(':3001', ':3000')

    [ 302, { 'Location' => location }, [] ]
  end

end
