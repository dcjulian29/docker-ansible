@docker run -it --rm -v "C:\code\ansible:/opt/ansible/etc:ro" dcjulian29/ansible %*

exit 0

docker run -it --rm --volume "$(pwd)":/ansible --workdir /ansible `
--env "AWS_ACCESS_KEY_ID='<AWS_Access_Key_ID>'" `
--env "AWS_SECRET_ACCESS_KEY='<AWS_Secret_Access_Key>'" `
dcjulian29/ansible

##AZURE
docker run -it --rm --volume "$(pwd)":/ansible --workdir /ansible `
--env "AZURE_SUBSCRIPTION_ID=<Azure_Subscription_ID>" `
--env "AZURE_CLIENT_ID=<Service_Principal_Application_ID>" `
--env "AZURE_SECRET=<Service_Principal_Password>" `
--env "AZURE_TENANT=<Azure_Tenant>" `
dcjulian29/ansible
