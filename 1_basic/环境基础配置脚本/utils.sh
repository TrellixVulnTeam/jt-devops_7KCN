#/bin/sh

LOG=/home/admin/install_pack.txt

install_pack() {
    local pack_name=$1
    echo "Installing ${pack_name}..." | tee -a ${LOG}
    yum install ${pack_name} -y |  tee -a ${LOG}
}

change_conf_attr() {
  local conf_file=${3}
  local key=${1}
  local value=${2}
  if [ -n $value ]; then
    #echo $value
    local current=$(sed -n -e "s/^\($key=\)\([^ ']*\)\(.*\)$/\2/p" ${conf_file})
    if [ -n $current ];then
      echo "setting $conf_file : $key=$value"
      value="$(echo "${value}" | sed 's|[&]|\\&|g')"
      sed -i "s|^[#]*[ ]*${key}\([ ]*\)=.*|${key}=${value}|" ${conf_file}
    fi
  fi
}