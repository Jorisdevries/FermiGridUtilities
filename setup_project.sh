project_name=$1
prestage=$2

#setup grid prerequisites
source /grid/fermiapp/products/common/etc/setups.sh
setup jobsub_client

#get samweb credentials
kx509
cigetcert -i "Fermi National Accelerator Laboratory"
voms-proxy-init -noregen -voms fermilab:/fermilab/uboone/Role=Analysis

#prestage dataset
if $prestage ; then
    echo "Staging files..."
    samweb prestage-dataset --defname=$project_name &> /dev/null
fi

