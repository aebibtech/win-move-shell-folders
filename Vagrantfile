# -*- mode: ruby -*-
# vi: set ft=ruby :

require_relative 'secrets.rb'
include Secrets

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|

  # config.vm.box = "gusztavvargadr/windows-10"
  config.vm.box = "gusztavvargadr/windows-server-2022-standard-core"

  config.vm.synced_folder ".", "/vagrant", type: "smb", smb_username: Secrets::SMB_User, smb_password: Secrets::SMB_Password

  config.vm.provision "shell", inline: <<-SHELL
     powershell -NoProfile -NoLogo -Command "& { Copy-Item -Path C:\\vagrant\\Files\\ -Destination C:\\Files -Force -Recurse }"
     powershell -NoProfile -NoLogo -File "C:\\vagrant\\Move-UserFiles.ps1" "C:\\Files"
   SHELL
end
