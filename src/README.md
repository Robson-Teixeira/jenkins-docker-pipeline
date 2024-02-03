## Ferramentas

- [VirtualBox](https://www.virtualbox.org/)
- [Vagrant](http://vagrantup.com)
- [Cmder](https://cmder.app/)

## Comandos

- `vagrant plugin install vagrant-disksize` permite aumento de disco no Vagrantfile
- `vagrant up` lê Vagrantfile e provisiona máquina
- `vagrant ssh` loga na máquina
    - `ps -ef | grep -i mysql` verifica se o MySQL está rodando
    - `mysql -u devops -p` e `mysql -u devops_dev -p` conectar ao servidor de banco de dados (senha _mestre_)
        - `show databases` lista banco de dados

### Instalando o Jenkins
- `cd /vagrant/scripts` acessa pasta de scripts
- `sudo ./jenkins.sh` executa arquivo de instalaçãoo do Jenkins
- `ip address` busca IP da máquina e acessar IP com porta 8080
- `sudo cat /var/lib/jenkins/secrets/initialAdminPassword` obtém valor chave (ativar Jenkins)
- `sudo usermod -aG docker $USER` | `sudo usermod -aG docker jenkins` adicionar usuário especificado ao grupo docker
- `vagrant reload` recarrega Vagrant (ler alterações do Vagrantfile, por exemplo)
