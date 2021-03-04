echo "[INFO]开始编译jt-platform-core项目"
echo $PWD
mvn clean && mvn install  -Dmaven.test.skip=true
echo "[INFO]jt-platform-core编译完成"