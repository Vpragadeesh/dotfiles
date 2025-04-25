#/bin/bash

packages=(
  btop
  fzf
  lsd
)

for x in ${packages[@]}; do 
  yay -S --noconfirm ${x}
done
