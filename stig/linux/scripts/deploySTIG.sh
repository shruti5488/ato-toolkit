echo "Installing scap-security-guide..."
yum -y install scap-security-guide
echo "Running hel7-script-stig.sh to deploy STIGs..."
bash /usr/share/scap-security-guide/bash/rhel7-script-stig.sh
echo "Deployment completed successfully."