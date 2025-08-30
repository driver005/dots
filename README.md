# DOTFILES

Add https://www.nerdfonts.com/ to terminal!!!

# Setup Nerd Fonts in Chrome OS terminal

Press `Ctr + Shift + j` to open devtools console in crostini terminal.

Paste this to use `Jetbrais Mono` with ligatures:
```js
term_.prefs_.set('font-family', 'JetBrains Mono Nerd Font, monospace');
term_.prefs_.set('user-css-text', '@font-face {font-family: "JetBrains Mono Nerd Font"; src: url("https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFont-Regular.ttf"); font-weight: normal; font-style: normal;} x-row {text-rendering: optimizeLegibility;font-variant-ligatures: normal;}')
```

1. To change font, replace url path to raw .ttf file with your font in [Nerd Fonts repository](https://github.com/ryanoasis/nerd-fonts/tree/master)
2. To disable ligatures, delete `x-row` class in `user-css-text` parameter

# Run

```bash
./setup.sh
```
