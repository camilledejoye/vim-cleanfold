# vim-cleanfold

CleanFold is a simple plugin to change the way folds are rendered in Vim.

I started by writing a simple foldtext() function corresponding to a specific FileType.
But I was anoyed that it works only for this FileType and I realize that the function was not
forced to be dependent of a FileType as long as some internal Vim's options were correctly
configured.

That's how CleanFold was born !

It was actually not meant to be distributed but I am used to handle my scripts as plugin
anyway, so why the hell not.

## What does it do ???

CleanFold will change the way folds are rendered, not how they are created.

* Replaces the dashes by spaces, you can change that if you want
* Removes the fold markers (can be disable)
* Handle multiline comments to avoir empty folds without meaning, Java anf PHP doc for example
* Allows to add handlers to manage differents situations

For more detail information, just try it and read the doc. I promise it's more elaborated !

## Installation

I recommend to use [k-takata/minpac](https://github.com/k-takata/minpac), it allows you to manage
your plugins with ease and work on Vim8 and NeoVim.
```vim
minpac#add('elythyr/vim-cleanfold')
```

Otherwise you know the drill :)

For instance with [Pathogen](https://github.com/tpope/vim-pathogen)
```
git clone https://github.com/elythyr/vim-cleanfold.git ~/.vim/bundle/vim-cleanfold
```
