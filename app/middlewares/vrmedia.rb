class Vrmedia < Struct.new(:app, :opts)

  PATTERN = /^\/vrmedia\/(\d+)(.+)$/ # e.g. /vrmedia/1-pj.m4a

  def call(env)
    return app.call(env) unless env['REQUEST_METHOD'] == 'GET'
    return app.call(env) unless md = env['PATH_INFO'].match(PATTERN)

    # this is a horrible hack for chrom(e|ium) in development
    # see http://stackoverflow.com/questions/21102690
    if Rails.env.development? and
      env['HTTP_USER_AGENT'].include?('Chrome')
      file = env["PATH_INFO"].split('/').last
      base = Settings.path_to_cloud
      raise "`path_to_cloud` not directory!" if File.directory?(base)
      path = %x[ find #{base} -name #{file} ].split("\n").first
      return [ 200, {}, File.open(path, 'r') ]
    end

    location = env['REQUEST_URI'].sub(':444', '').sub(':3001', ':3000')
    [ 302, { 'Location' => location }, [] ]
  end

end
