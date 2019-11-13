#!/bin/bash -x
#while [ -n "$1" ]
#do
#case "$1" in
#--skip-test-db) testdb=$1; echo "Found the $testdb option" ;;
#--cdn-clean) cdn=$1; echo "Found the $cdn option" ;;
#--memcache-clean) memcache=$1; echo "Found the $memcache option" ;;
#*) echo "$1 is not an option" ;;
#esac
#shift
#done
repo_path="/home/meccano/project"
release_path="/home/meccano/releases"
shared_path="/home/meccano/shared"
cd $repo_path
#git pull |grep 'Already up-to-date.' && \
yes | git checkout master && git pull origin master && \
#if [ "$?" -ne "0" ];then

git submodule init && \
git submodule foreach git checkout -- . && \
yes | git submodule update && \
git submodule foreach git checkout master && \
git submodule foreach git pull origin master && \

composer install --no-dev --no-interaction --no-progress --optimize-autoloader && \
old_version=`ls -ll $release_path/current |awk -F\/ '{print $NF}'` && \

echo "old version was $old_version use it for otkat.sh in case deploy problems" && \
version=`date '+%Y%m%d%H%M%S'`  && \

mkdir -p $release_path/$version  && \
cp -R $repo_path/. $release_path/$version/  && \
#cp -R $release_path/current/frontend/node_modules $release_path/$version/frontend  && \
#cp -R $release_path/current/bower_components $release_path/$version/  && \
#if [ -d "$release_path/current/vendor" ]; then
#    cp -R $release_path/current/vendor $release_path/$version/
#else
#  echo "Not found  vendor directory"
#fi && \

#chown -R meccano:meccano $release_path/$version  && \
echo "install composer" && \
#$shared_path/install.sh $version  && \
cd $release_path/$version/ && \
php init --env=Production --overwrite=y && \
#composer install --no-dev --no-interaction --no-progress --optimize-autoloader && \
#yes | php yii migrate && \
#build web socket
#cd mega-messages  && \
#npm install --no-bin-links --production && \

echo "install npm" && \
#build frontend
cd frontend  && \
npm install --no-bin-links && \
# --production && \
npm run build && \
cd ../cabinet && \
npm install --no-bin-links && \
npm run build


rm -Rf $release_path/$version/api/runtime  && \
rm -Rf $release_path/$version/runtime  && \
rm -Rf $release_path/$version/console/runtime  && \

cp $release_path/current/yii $release_path/$version/  && \

ln -s $shared_path/api/runtime $release_path/$version/api/runtime  && \
ln -s $shared_path/runtime $release_path/$version/runtime  && \
ln -s $shared_path/console/runtime $release_path/$version/console/runtime  && \

rm -Rf $release_path/$version/api/config/{main-local.php,params-local.php,test-local.php}  && \
ln -s $shared_path/api/config/main-local.php $release_path/$version/api/config/main-local.php  && \
ln -s $shared_path/api/config/params-local.php $release_path/$version/api/config/params-local.php  && \
ln -s $shared_path/api/config/test-local.php $release_path/$version/api/config/test-local.php  && \

rm -Rf $release_path/$version/console/config/{main-local.php,params-local.php,test-local.php}  && \
ln -s $shared_path/console/config/main-local.php $release_path/$version/console/config/main-local.php  && \
ln -s $shared_path/console/config/params-local.php $release_path/$version/console/config/params-local.php  && \
ln -s $shared_path/console/config/test-local.php $release_path/$version/console/config/test-local.php  && \

rm -Rf $release_path/$version/common/config/{main-local.php,params-local.php,test-local.php}  && \
ln -s $shared_path/common/config/main-local.php $release_path/$version/common/config/main-local.php  && \
ln -s $shared_path/common/config/params-local.php $release_path/$version/common/config/params-local.php  && \
ln -s $shared_path/common/config/test-local.php $release_path/$version/common/config/test-local.php  && \

#chown -R meccano:meccano $release_path/$version  && \
ln -sfn $release_path/$version $release_path/current  && \
#chown meccano:meccano $release_path/current
if [ "$?" -ne "0" ]; then
exit 1
fi

cd $release_path/$version
php yii migrate/new all | grep 'No new migrations found'

current_version=`ls -ll $release_path/current |awk -F\/ '{print $NF}'`
ls -lr $release_path/ |grep -v $current_version |tail -n +5 |awk '{print $NF}'|xargs -n1 -I {} rm -Rf $release_path/{}  && \
# crontab $repo_path/ci/crontab

#rm -Rf /home/meccano/public_html/megaflowers/runtime/Pug/*
if ! [ -z $memcache ]; then
echo "clean cache"
#docker restart memcached
fi
php yii cache/flush-all


echo "old version was $old_version use it for otkat.sh in case deploy problems"
#fi

sudo service php7.3-fpm restart
cd $release_path/$version
forever stopall && ./services.sh

