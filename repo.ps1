#!/usr/bin/env pwsh
#title           :repo
#description     :
#author          :thulin82
#date            :20230201
#version         :0.1
#usage           :Run from git root folder
#notes           :

function Get-Changes {

    Push-Location ".."

    $branch= &git rev-parse --abbrev-ref HEAD
    Write-Host "Current branch: " $branch
    
    if ($defaultBranches -Contains $branch) {

        if(git status --porcelain | Where-Object {$_ -match '^\?\?'}){
            # There are untracked files, abort
            Write-Host "There are untracked files" -ForegroundColor red
        } 
        elseif(git status --porcelain | Where-Object {$_ -notmatch '^\?\?'}) {
            # There are uncommited changes, abort
            Write-Host "There are uncommitted changes" -ForegroundColor red
        }
        else {
            # Tree is clean, proceed
            $branch= &git rev-parse --abbrev-ref HEAD

            $head = &git rev-parse $branch
            $origin = &git rev-parse origin/$branch

            if ($head -ne $origin) {
                # There are changes to be fetched from origin
                Write-Host "Pulling changes on branch " $branch -ForegroundColor blue
                git pull
            } else {
                # Origin and local repository are in sync
                Write-Host "Already up to date" -ForegroundColor green
            }
        }
    } else{
        # Another branch than the defaults was used, abort
        Write-Host "Not on master/main, will not pull changes automatically" -ForegroundColor red
        
    }
    Write-Host ""
    Pop-Location
}

$folders = Get-ChildItem -Path . -Filter .git -Recurse -Depth 1 -Force -Directory |
                Select-Object -expandproperty fullname

$defaultBranches = ("master", "main")

Foreach ($i in $folders)
{
    Write-Host "Git fetch: " $i -ForegroundColor yellow
    Push-Location $i
    git fetch --prune

    Get-Changes

    Pop-Location
}