<div align="center">
  <img src="img/logo.webp" alt="Logo" />
</div>

<div align="center">
  <h1>NaryaVim</h1>
  <p>A configuration for Neovim that inspires hope and resolution 🔥</p>
</div>

<div align="center">
  <img src="https://img.shields.io/badge/Neovim-0.8%2B-green?style=flat&logo=neovim" />
  <img src="https://img.shields.io/github/license/lcfd/NaryaVim?label=License&logo=GNU&style=flat" />
</div>

- [⭐️ Why](#️-why)
- [💾 Install](#-install)
- [🏋️‍♀️ Usage](#️️-usage)
- [🔢 Neovim version](#-neovim-version)
- [📸 Screenshots](#-screenshots)

## ⭐️ Why

I wanted a config that was truly mine and that would help me be fast and accurate
in coding.

Neovim configurations are really personal.
I hope that this repository will be a source of inspiration for you.

This configuration is intended to be used primarily with:

- Django
- Pelican
- TailwindCSS

I will add specific support to other technologies.

## 💾 Install

Clone the repository in the `nvim` config folder.

```shell
git clone https://github.com/lcfd/NaryaVim ~/.config/nvim
```

Make sure to update and compile the plugins.

Inside Neovim:

`:PackerSync`

Or in your shell:

`nvim +PackerSync`

Create a virtual environment for Python development:

`python3 -m venv ~/.config/nvim/venv`

Install `pynvim`

`~/.config/nvim/venv/bin/pip install pynvim`

## 🏋️‍♀️ Usage

Read the [wiki](https://github.com/lcfd/NaryaVim/wiki).

## 🔢 Neovim version

I'm using this configuration in Neovim `0.8`.

## 📸 Screenshots

![screenshot-1](img/screen-1.png "screenshot 1")
