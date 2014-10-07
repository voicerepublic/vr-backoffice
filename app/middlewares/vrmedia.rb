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
      base = File.expand_path(base,Dir.pwd)
      raise "`path_to_cloud` not directory!" unless File.directory?(base)
      paths = %x[ find #{base} -name #{file} ].split("\n")
      return [ 200, {}, File.open(paths.first, 'r') ]
    end

    Rails.logger.info env.inspect

    location = env['REQUEST_URI'].sub(':444', '').sub(':3001', ':3000')
    [ 302, { 'Location' => location }, [] ]
  end

end
