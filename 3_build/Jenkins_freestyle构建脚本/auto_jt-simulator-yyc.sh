cd ${WORKSPACE}/simulator-provider-report-yyc  && \
mvn clean && mvn install && \
cp target/simulator-provider-report-yyc-1.0.0.RELEASE.jar  /opt/build/platform/lib/
cd ${WORKSPACE}
ansible-playbook   main.yml
echo "service update successful...."