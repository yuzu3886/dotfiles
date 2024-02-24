define :dotfile do
  if params[:name].is_a?(String)
    links = { params[:name] => params[:name] }
  else
    links = params[:name]
  end

  links.each do |link_from, link_to|
    link_from = File.join(ENV['HOME'], link_from)

    directory File.dirname(link_from) do
      user node[:user]
    end

    link link_from do
      to File.expand_path("../../../config/#{link_to}", __FILE__)
      user node[:user]
      force true
    end
  end
end
