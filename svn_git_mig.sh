# migration-svn-to-git-on-linux
#!/bin/bash
echo "Insert the SVN project url"
read svnurl
echo "Insert the name file while it will be placed in /opt/"
read authorfilename
echo "Insert your folder name to be created in /opt/svngitmig/"
read workspace
echo "Insert the git URL:"
read giturl
echo "Generating Author file"
{ svn log -q $svnurl ; } | awk -F '|' '/^r/ {sub("^ ", "", $2); sub(" $", "", $2); print $2" = "$2" <"$2"@domain.com>"}' | sort -u > /opt/$authorfilename.txt;

echo "Generating Workspace"
mkdir -p /opt/svngitmig/$workspace
cd /opt/svngitmig/$workspace

echo "Initialization of the git project"
git svn init  $svnurl

echo "Fetch Project with all tags and branches" 
git svn fetch --fetch-all -A /opt/$authorfilename.txt

echo "remoting with GITLAB"
git remote add origin $giturl

echo "Total remote branches"
git branch -r | wc -l

echo "Branches only"
git branch -r | grep -v "tags" | wc -l

echo "Tags only"
git branch -a | grep "remotes/tags/"

echo "Migrate BRANCHES only"
for branch in `git branch -r | grep -v "tags/"` 
do 
git branch --track ${branch##*/} $branch; 
done

echo "List local branches"
git branch | wc -l

echo "Migrate TAGS only"
for branch in `git branch -a | grep "remotes/tags/"`; 
do 
git tag ${branch##*/} $branch; 
done

echo "Liste local TAGS"
git tag -l | wc -l

for branch in `git branch`
do 
echo "checkout to $branch"
git checkout $branch;
echo "creating gitkeep in empty folders"
find . -type d -empty -exec touch {}/.gitkeep \;
echo "adding the changes"
git add .
echo " commit the changes" 
git commit -m "add gitkeep in empty folder"
echo "pushing to remaote branch"
git push 
done

echo "bring the ACTION"

