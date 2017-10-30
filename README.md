## is.vim - incremental search improved

[![Build Status](https://travis-ci.org/haya14busa/is.vim.svg?branch=master)](https://travis-ci.org/haya14busa/is.vim)

is.vim improves search feature.
is.vim is successor of [incsearch.vim](https://github.com/haya14busa/incsearch.vim).

'is' is abbreviation of 'incsearch'.

## :sparkles: Feature :sparkles:

### Automatically clear highlight (|:nohlsearch|) after cursor moved and some other autocmd event.

![is-auto-nohlsearch](https://raw.githubusercontent.com/haya14busa/i/37cb1f7eec116eeb43768103bcfa0853b0bddddb/is.vim/is-auto-nohlsearch.gif)

### Incremental scroll to next match feature.

![is-scroll](https://raw.githubusercontent.com/haya14busa/i/37cb1f7eec116eeb43768103bcfa0853b0bddddb/is.vim/is-auto-nohlsearch.gif)

## :electric_plug: Integration :electric_plug:

is.vim can integrate with other search enhancment plugins.

### Integration of vim-anzu
https://github.com/osyo-manga/vim-anzu display search position like (2/10) for n/N commands.

```vim
map n <Plug>(is-nohl)<Plug>(anzu-n-with-echo)
map N <Plug>(is-nohl)<Plug>(anzu-N-with-echo)
```

### Integration of vim-asterisk
https://github.com/haya14busa/vim-asterisk provides improved * motions.

- * motion without cursor move
- visual star feature (search selected text)
- etc..

```vim
map *  <Plug>(asterisk-z*)<Plug>(is-nohl-1)
map g* <Plug>(asterisk-gz*)<Plug>(is-nohl-1)
map #  <Plug>(asterisk-z#)<Plug>(is-nohl-1)
map g# <Plug>(asterisk-gz#)<Plug>(is-nohl-1)
```

