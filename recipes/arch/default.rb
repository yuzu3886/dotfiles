dotfile '.config/alacritty'
dotfile '.config/fontconfig'
dotfile '.config/git'
dotfile '.config/i3'
dotfile '.config/picom'
dotfile '.config/tmux'
dotfile '.vim'
dotfile '.zshenv'
dotfile '.zshrc'

package 'alacritty'
package 'firefox'
package 'firefox-i18n-ja'
package 'i3-wm'
package 'i3status-rust'
package 'noto-fonts'
package 'noto-fonts-cjk'
package 'noto-fonts-emoji'
package 'picom'
package 'pipewire'
package 'pipewire-pulse'
package 'polkit'
package 'rofi'
package 'tmux'
package 'xclip'
package 'xorg-server'
package 'xorg-xinit'
package 'xsecurelock'

include_recipe 'paru'

paru 'ttf-udev-gothic'

# xsecurelock
remote_file '/etc/systemd/system/xsecurelock@.service' do
  owner 'root'
  group 'root'
  mode '644'
end

service "xsecurelock@#{node[:user]}" do
  action :enable
  user 'root'
  provider :systemd
end
