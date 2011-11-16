class StaticFileServer
  def self.app(root)
    StaticFileServer.new nil, :root => root
  end

  def initialize(app=nil, options={})
    @app  = app
    @root = options[:root] || File.expand_path(File.join(File.dirname(__FILE__), ""))
    @path ||= options[:path]
  end           

  def call(env)
    # Extract the requested path from the request
    req = Rack::Request.new(env)

    root = @root

    unless @path.nil?
      pass_to_next = true unless @path.match req.path_info
      if pass_to_next
        return @app.call(env)
      else
        req.path_info.sub! @path, ''
      end
    end

    index_file = File.join(@root, req.path_info, "index.html")

    if File.exists?(index_file)
      # Rewrite to index
      req.path_info += "index.html"
    end
    
    puts "#{@root}/#{req.path_info}"

    # Pass the request to the directory app
    Rack::Directory.new(@root).call(env)
  end
end

@video_root = File.expand_path(File.join(File.dirname(__FILE__), "../../proto/limo/video"))
@data_root = File.expand_path(File.join(File.dirname(__FILE__), "../../proto/limo/limo/test/data"))

run StaticFileServer.app File.expand_path(File.join(File.dirname(__FILE__), ""))
