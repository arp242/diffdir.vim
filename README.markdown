Simple Vim directory diff.

Usage:

    :Diffdir dir1 dir2

This will open all files with changes in a tab as a diff.

And that's pretty much it 😅 It will ignore the `.git` directory, but there's no
special handling of anything outside of that.

This is a lot simpler than [vim-dirdiff], with the downside that it's a wee bit
slower to start as it needs to read everything on startup. The upshot of this is
we don't need any special mappings, commands, etc.

You can start it from the commandline with 

    $ vim +':Diffdir dir1 dir2'

Or as:

    diffdir() {
        dir1=$(printf '%q' "$1")
        dir2=$(printf '%q' "$2")
        shift; shift;
        vim $@ +":Diffdir $dir1 $dir2"
    }

Other solution can be found at [How to diff and merge two directories?][vi]

[vim-dirdiff]: https://github.com/will133/vim-dirdiff
[vi]: https://vi.stackexchange.com/q/778/51
