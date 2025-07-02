wget -O installer "https://github.com/fosrl/pangolin/releases/download/undefined/installer_linux_$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')" && chmod +x ./installer

The installer will prompt you for the following basic information. For example:

#Base Domain Name: Enter your base fully qualified domain name (without any subdomains) Example: example.com
#Dashboard Domain Name: The domain where the application will be hosted. This is used for many things, including generating links. 
#You can run Pangolin on a subdomain or root domain. Example: pangolin.example.com
#Let's Encrypt Email: Provide an email address for SSL certificate registration with Lets Encrypt. This should be an email you have access to.
#Tunneling You can choose not to install Gerbil for tunneling support - in this config it will just be a normal reverse proxy. See how to use without tunneling.

Base Domain Name: mydomainname.one
Dashboard Domain Name: pangolin1.mydomainname.one
Lets Encrypt Email: emailid@mydomainname.one
Gerbil to allow: YES

Enter Admin User Email: pangolin1@mydomainname.one
Create Admin User Password: *****
Confirm Admin User Password: *****

Signup Without Invite: defaults to disabled
Organization Creation: defaults to enabled
Email Configuration: NO
Docker Installation: YES
Crowdsec Installation: NO
Container Deployment: YES
Post-Installation: https://<your-domain>/auth/initial-setup

# You can log in using the admin email and password you provided
# Create your first organization, site, and resources


ref-1: https://docs.fossorial.io/Getting%20Started/quick-install
ref-2: https://technat.ch/posts/pangolin/

