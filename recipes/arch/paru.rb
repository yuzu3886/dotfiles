version = 'v2.0.1'
archive = "paru-#{version}-x86_64.tar.zst"
url = "https://github.com/Morganamilo/paru/releases/download/#{version}/#{archive}"

execute "curl -fsSL -o /tmp/#{archive} #{url}" do
  user node[:user]
  not_if 'command -v paru'
end

execute "zstd -dc /tmp/#{archive} | tar -xf -" do
  user node[:user]
  not_if 'command -v paru'
  cwd '/tmp'
end

execute '/tmp/paru -Syu paru-bin --noconfirm --noprovides' do
  user node[:user]
  not_if 'command -v paru'
end

define :paru do
  name = params[:name].shellescape
  execute "paru -Syu #{name} --noconfirm --noprovides" do
    user node[:user]
    not_if "paru -Q #{name} || paru -Qg #{name}"
  end
end
