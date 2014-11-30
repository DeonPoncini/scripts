---
Title: scripts
Description:
Author: Deon Poncini

---
scripts
===============

Developed by Deon Poncini <dex1337@gmail.com>

Downloads
---------

Description
-----------
This script is intended to support projects that use multiple git
repositories, and allow composibility between libraries.
A common project structure will look like this:

    projectA/
        liba/
        libb/
        libc/
        exe/

Such a usecase is easily supported by the repo tool today, by adding these
projects to a repo manifest. repo will ensure that the CMakeLists.txt can
work with relative paths, i.e. the base CMakeLists includes ../libA etc

The problem happens when there is a second project like so:

    projectB/
        liba/
        libb/
        libd/
        exe/

Project B uses liba and libb from projectA, and introduces a new library libd.
There are two alternatives - add the libd and main project to the repo
manifest of libd, forcing a complicated build structure and unnecessary
downloads, or have multiple copies of liba, libb on your system. Multiple
copies has the downside that local changes are hard to move between projects
without committing the work.

The other issue with these multiple repository solutions is where to put the
CMakeLists.txt file. In a traditional single repository, it would go at the
root level like so:

    projectB/
        liba/
        libb/
        libd/
        exe/
        CMakeLists.txt

However once we put each folder in its own repo, it cannot live at this level.
So we need to either use the main program CMakeLists.txt include its library
dependencies through relative paths, or we need a separte repo just for the
make script.

The other problem here is we have now stated our dependencies twice: once in
the repo manifest, and a second time in the CMakeLists.txt

This build system hopes to solve those problems. The repo manifest format is
retained by this build system, so the projects can used with the regular
repo tool if desired. The build system allows for building projects out of
source code libraries that can be simulatenously used by other projects
in the same project workspace

To create a project that works with this build system, you need to create a
repo manifest detailing the projects that compose the project. Once this is
done add this a git repository you control that will store all your project
manifests. All projects you want to work with this build system and share
libraryes must have their repo manifests in the same git repository.

To setup the build system you need to add a user.sh file to specify the path
to the git repository that stores all your repo manifest files, and the
basename of the directory you want to save these files in.

To use the build system, create a project workspace folder, then

    export PROJECT_NAME=<name>
    source open-project.sh

This name should exactly match the name of your repo manifest file, without
the .xml extension. This will update the manifest repo and then figure out what
git repositories are needed by this project. This is equivalent to a repo init,
and will create an artifact directory for all project artifacts to live in.

Your shell prompt will be updated with your current project name. If you move
into a git repository that will show on the prompt to, but not any
subdirectories you will move into, it will stay labelled with the repo name.

To clone the repositories, use the project-vcs tool. This works to issue
git commands to all repositories active in the current project. Run

    project-vcs clone

and it will clone all repositories that don't exist and
update those that do.

Lets see how the example projects above will look after the following:

Before we do anything, we just have our project root and this scripts git
repo we have checked out under it:

    project_root/
        scripts/

we cd in there and

    export PROJECT_NAME=projectA
    source open-project.sh

it now looks like the following:

    project_root/
        _artifacts/projectA/
        scripts/
        manifest/

we then do

    project-vcs clone

it now looks like the following:

    project_root/
        _artifacts/projectA/
        scripts/
        manifest/

we then do

    project-vcs clone

it now looks like the following:

    project_root/
        _artifacts/
        liba/
        libb/
        libc/
        projectA/
        scripts/
        manifest/

We now want to start working on projectB, we can do the following:

    export PROJECT_NAME=projectB
    source open-project.sh
    project-vcs clone

Our directory looks like this:

    project_root/
        _artifacts/projectA
        _artifacts/projectB
        liba/
        libb/
        libc/
        libd/
        projectA/
        projectB/
        scripts/

liba and libb were just updated to HEAD, libd and projectB were newly cloned.
When we run commands using project-vcs it only effects the project that is
currently open, for example if we do a project-vcs pull now, only liba, libb
libd and projectB would be updated. If we then

    export PROJECT_NAME=projectA
    source open-project.sh
    project-vcs pull

liba, libb, libc and projectA would be updated only.

It is useful that downstream binaries can easily include upstream libraries
that are being compiled in at the same time. To support this, there is a useful
export\_project macro that can be added to each project. This will
export and install the project in the install directory along with exposing
the include directories, libraries, binaries and archives to any projects that
wish to use them. Project exconfig is the project that uses this system.

Building is a simple process once all this is set up, simply type build, which
compiles all the projects in the project and installs their output in
\_artifact/name/install.

Building
--------

    mkdir project_root
    cd project_root
    export PROJECT_NAME=<name>
    touch scripts/user/user.sh
    echo '#!/bin/bash' >> scripts/user/user.sh
    echo 'export MANIFEST_GIT="user@gitpath.com/manifest.git"' >> scripts/user/user.sh
    echo 'export MANIFEST_DIR="manifest"' >> scripts/user/user.sh
    source scripts/open-project.sh
    project-vcs clone
    build

Usage
-----
See build help and project-vcs help

License
-------
Copyright (c) 2014 Deon Poncini.
See the LICENSE file for license rights and limitations (MIT)
