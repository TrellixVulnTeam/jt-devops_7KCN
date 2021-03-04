echo "[INFO]开始编译jt-commons项目"
echo  $PWD
mvn clean && mvn install   -Dmaven.test.skip=true
echo "[INFO]jt-commons项目编译完成..."