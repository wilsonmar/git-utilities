# gup.sh
# git update shell script, using push and pop of directories.

pushd
cd ~/gits/wilsonmar/futures
git add .
git commit -m"update via upg.sh"
git push
popd
