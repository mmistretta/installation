#!/usr/bin/env bash

#check the current branch we are on
currentBranch=$(git branch | grep \* | cut -d ' ' -f2)

#print the branch and wait for a continue

echo "currently on branch $currentBranch do you wish to continue with the release? (y/n)"
read  -n 1 -p "Input: " carryON


if [[ "$carryON" != "y" ]]
then
echo "
exiting"
exit
fi


#ask if a release branch is needs to be created

echo "
do you want a release branch created ? (y/n)"
read  -n 1 -p "Input: " carryON


if [[ "$carryON" == "y" ]]
then
echo "
what branch do you want?"
read  -p "Input: " branch
echo "
creating new branch $branch
"

git checkout -b ${branch}

if [[ $? > 0 ]]
then
exit "command failed" $?
fi

fi

#check we are upto date and no local changes
dirty=$(git ls-files -m | wc -l)
if [[ "${dirty}" -gt "0" ]]
then
echo "
 the local file system is dirty cannot continue
"
exit
fi

echo "
what release version do you want to create (e.g. release-v1.3.0-rc1)?"
read  -p "Input: " release

releaseExists=$(git tag | grep release-1.2.0-rc6 | wc -l)
if [[ ${releaseExists} > 0 ]]
then
echo "
a release with that name already exists
"
exit
fi

#update the manifest with the release tag
sed -i.bak -E "s/^integreatly_version: .*$/integreatly_version: $release/g"  ./evals/inventories/group_vars/all/manifest.yaml && rm ./evals/inventories/group_vars/all/manifest.yaml.bak

#commit the change and push
git commit -am "release manifest version  update for $release"
git push origin ${branch}
#tag and push
git tag ${release}
git push origin ${release}