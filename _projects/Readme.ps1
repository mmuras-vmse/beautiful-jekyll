<# I am using this file to Guide me through Presentation and blog posts
#
#
# TODO: 1. Git Integration with Git Hub

    start-process chrome.exe "http://www.notyourdadsit.com/blog/2018/4/3/cheatsheet-setup-github-on-visual-studio-code"

    I usually access github from within Visual Studio Code.  As such, when I start coding a new project, I often need a reminder, or a cheat sheet for how to connect Visual Studio Code to a Git repository.  These notes are more for me than for anyone else, but I'm sharing them nonetheless.

        Steps:
            1. Create a directory on the local file system.

            2. Create a repo on Github.

            3. Select Clone "Clone or download" on Github, copy the link

            4. In Visual Studio Code, sect File -> Add Folder to Workspace -> Select the newly created directory

            5. Select Terminal Window
            
            6. In the window, type:
                git config --global user.name <github userID>

                git clone <URL from github link copied earlier>

                That should be all that's required.  any newly created file should be available on github after stage/commit/push.

#=========================================================================================
#
##  ? How to Get data from Git-Hub

    1. git pull # (downloads repository with latest changes)

    2. Make code changes

    3. Save file

    4. Stage Changes (hit '+' icon)

    5. Commit Changes (hit 'check' icon) and type commit message and press ENTER key

    6. git push # (uploads data from local copy to respository)


#>