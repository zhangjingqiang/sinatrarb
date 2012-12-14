require "sinatra"
require "open-uri"

set :partial_template_engine, :erb

configure :production do
    set :raise_errors, false
    set :show_exceptions, false
end

before do
    @google = 'http://www.google.com'
    @google_search = 'http://www.google.com/search?sitesearch=www.sinatrarb.com&as_q='
end

helpers do
    def sinatrarb(keyword = NULL)
        url = URI.escape("#{@google_search + keyword}")
        doc = Nokogiri::HTML(open(url), nil, "UTF-8")
        @content = Hash.new{|h, key| h[key] = []}
        doc.css("h3 a").each do |site|
            @content[:site_href] << site[:href]
            @content[:site_text] << site.text
        end
        doc.css("div[class='s'] span").each do |description|
            @content[:description] << description
        end
        @content
    end
end

get '/' do
    @content = sinatrarb('')
    erb :index
end

get '/search' do
    @content = sinatrarb(params[:s])
    erb :index
end

