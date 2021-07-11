if exists('g:loaded_diffdir') | finish | endif
let g:loaded_diffdir = 1
let s:save_cpo = &cpo
set cpo&vim

comm! -complete=dir -nargs=+ Diffdir call s:diffdir(<f-args>)

fun! s:diffdir(dir1, dir2) abort
	for f in s:tree(a:dir1)->extend(s:tree(a:dir2))->sort()->uniq()
				\ ->map({_, f -> [s:joinpath(a:dir1, f), s:joinpath(a:dir2, f)] })
				\ ->filter({_, f -> s:has_diff(f[0], f[1])})
		if !s:empty_buf()
			tabnew
		endif
		silent exe 'e' fnameescape(f[1])
		exe 'vert diffsplit' fnameescape(f[0])
	endfor
	tabfirst
endfun

fun! s:tree(root) abort
	let tree = []
	for f in readdirex(a:root)
		let path = s:joinpath(a:root, f.name)
		if s:ignore(path, f)
			continue
		endif

		if f.type is# 'dir'
			call extend(tree, s:tree(path))
		else
			call add(tree, path->split('/')[1:]->join('/'))
		endif
	endfor
	return tree
endfun

" TODO: probably want to expand this a bit, as well as allow something like:
"   Diffdir -ignore foo dir1 dir2
fun! s:ignore(path, file) abort
	if a:file.type is# 'dir' && a:file.name is# '.git'
		return v:true
	endif
	return v:false
endfun

" TODO: We could speed this up a bit if we extend s:tree() to compare this, as
" readdirex() already gives us the stat(); but this seems Fast Enough™ for now.
fun! s:has_diff(file1, file2) abort
	if getfsize(a:file1) isnot getfsize(a:file2)
		return v:true
	endif
	return a:file1->readfile()->join('\n')->sha256() isnot a:file2->readfile()->join('\n')->sha256()
endfun

fun! s:empty_buf() abort
	return winnr('$') is# 1 && bufname('') is# '' && line('$') is 1 && getline('.') =~ '^\s*$'
endfun

fun! s:joinpath(...) abort
	return a:000->join('/')->substitute('^\./', '', '')
endfun

let &cpo = s:save_cpo
unlet s:save_cpo
