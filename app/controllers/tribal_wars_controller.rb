class TribalWarsController < ApplicationController

  def get
    params.delete('controller')
    params.delete('action')
    if (!params.empty?)
      elements = params.to_query
    else
      elements = 'screen=place'
    end
    default_url = "/game.php?#{elements}"
    base = "https://#{User.current.world}.tribalwars.com.br"
    render :text => convert_links(client.get(base + default_url))
  end

  def post
    params.delete('controller')
    params.delete('action')
    if (!params.empty?)
      elements = params.to_query
    else
      elements = 'screen=place'
    end
    default_url = "/game.php?#{elements}"
    base = "https://#{User.current.world}.tribalwars.com.br"
    render :text => convert_links(client.post(base + default_url,request.request_parameters))
  end

  def convert_links (page)
    doc = Nokogiri::HTML(page.content)
    doc.search('#storage').remove_attr('style')

    # <a id="main_buildlink_main_cheap" href="/game.php?village=18297&amp;screen=main&amp;action=upgrade_building&amp;id=main&amp;type=main&amp;h=97ca8334&amp;cheap" data-building="main" data-cost="30" class="btn  btn-bcr ">-20%</a>


    return doc.to_html
  end

  def client
    Mobile::Client.client
  end

end
