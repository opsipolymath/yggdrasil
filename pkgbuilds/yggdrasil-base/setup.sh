#!/bin/bash

_get_dotfiles() {
	local DOTDIR="$HOME"/.config/dotfiles
	local GIT_USER=opsipolymath
	local GIT_REPO=dotfiles.git
	local REPO_HTTPS="https://github.com/${GIT_USER}/${GIT_REPO}"
	local REPO_SSH="git@github.com:${GIT_USER}/${GIT_REPO}"
	readonly DOTDIR GIT_USER GIT_REPO REPO_HTTPS REPO_SSH

	[[ -e "$DOTDIR" ]] && {
		printf 'Dotfiles directory already exists; aborting\n'
		return 1
	}

	_dotgit() {
		git --git-dir="${DOTDIR}" "$@"
	}

	git clone -q --bare "$REPO_HTTPS" "$DOTDIR" || {
		printf 'Failed cloning %s\n' "$GIT_REPO" >&2
		return 1
	}
	
	_dotgit --work-tree="$HOME" read-tree HEAD || {
		printf 'Failed reading tree\n' >&2
		return 1
	}
	_dotgit --work-tree="$HOME" update-index --skip-worktree ".github/README.md" || {
		printf 'Failed skipping README\n' >&2
		return 1
	}
	
	_dotgit --work-tree="$HOME" checkout-index -a || {
		printf 'Failed checking out dotfiles\n' >&2
		return 1
	}
	
	_dotgit config --replace-all remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*' || {
		printf 'Failed updating refspec for origin\n' >&2
		return 1
	}
	_dotgit config branch.main.remote origin || {
		printf 'Failed setting tracking branch\n' >&2
		return 1
	}
	_dotfit config branch.main.merge refs/heads/main || {
		printf 'Failed setting merge spec\n' >&2
		return 1
	}
	_dotgit fetch -q origin || {
		printf 'Failed fetching origin\n' >&2
		return 1
	}
	_dotgit remote set-url origin "$REPO_SSH" || {
		printf 'Failed setting remote to use ssh\n' >&2
		return 1
	}
}

_get_dotfiles
